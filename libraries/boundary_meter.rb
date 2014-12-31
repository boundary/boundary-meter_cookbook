#
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Cookbook Name:: boundary-meter
# Library:: boundary_meter
#
# Copyright 2014, Boundary
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Boundary
  class Meter
    attr_accessor :node

    CONF_DIR='/etc/boundary'

    def initialize(node)
      @node = node
    end

    def get(resource)
      result = `boundary-meter -l json -b #{Boundary::Meter::CONF_DIR}`
      raise Exception.new("boundary meter status failed") unless $?.to_i == 0
      JSON.parse(result)
    end

    def provisioned?(resource)
      meter = get(resource)
      (meter['id'] and meter['connected'] == 'true') or \
          (meter['premium'] and meter['premium']['projectId'])
    end

    def setup_conf_dir(resource)
      ::Dir.mkdir(resource.conf_dir) unless ::File.directory?(resource.conf_dir)
      ::FileUtils.cp "#{Boundary::Meter::CONF_DIR}/ca.pem", "#{resource.conf_dir}/" unless ::File.exists?("#{resource.conf_dir}/ca.pem")
    end

    def remove_conf_dir(resource)
      if ::File.directory?(resource.conf_dir) && resource.conf_dir != Boundary::Meter::CONF_DIR && resource.conf_dir.include?(Boundary::Meter::CONF_DIR)
        ::FileUtils.rm Dir.glob "#{resource.conf_dir}/*"
        ::Dir.rmdir resource.conf_dir
      end
    end

    def build_command(resource, action)
      command = [
          "boundary-meter -l #{action.to_s}",
          "-L https://#{node['boundary_meter']['api']['hostname']}",
          "-P https://#{node['boundary_meter']['premium-api']['hostname']}",
          "-p #{resource.token}",
          "-b #{resource.conf_dir}",
          "-n tls://#{node['boundary_meter']['collector']['hostname']}:#{node['boundary_meter']['collector']['port']}",
          "--nodename #{resource.node_name}"
      ]

      if action == :create
        tags = collect_tags

        command.push "--tag #{tags}" unless tags == ''

        if node['boundary_meter']['enable_stun'] == 1
          command.push "--enable-stun"
        end
      end

      return command.join(' ')
    end

    def run_command(command)
      Chef::Log.info(command)

      cmd = Mixlib::ShellOut.new(command)
      cmd.run_command
      cmd.error!
    end

    def exists?(resource)
      # If meter is running but is an unprovisioned state return false
      ::File.exists?("#{resource.conf_dir}/meter.conf") and
          provisioned?(resource)
    end

    def create(resource)
      setup_conf_dir resource

      Chef::Log.info("Creating meter [#{resource.name}]")

      begin
        run_command build_command resource, :create
      rescue Exception => e
        Chef::Log.error("Could not create meter [#{resource.name}], failed with #{e}")
      end
    end

    def config_merged?(resource)

      conf_file = "#{resource.conf_dir}/meter.conf"

      if File.exist?(conf_file) && !File.zero?(conf_file)
        old_config = JSON.load(::File.new("#{resource.conf_dir}/meter.conf"))
        new_config = old_config.merge(node['boundary_meter']['meter_conf'])
        if old_config.eql?(new_config)
          Chef::Log.info("No new meter.conf settings detected ... skipping update.")
          return false
        else
          Chef::Log.info("New meter.conf settings detected. Updating #{conf_file} ...")
          File.open("#{resource.conf_dir}/meter.conf", 'w+') { |file| file.write(JSON.pretty_generate(new_config)) }
          return true
        end
      else
        Chef::Log.info("Old Config [#{conf_file}] does not exist!")
        return false
      end


    end

    def delete(resource)
      remove_conf_dir resource

      Chef::Log.info("Deleting meter [#{resource.name}]")

      begin
        run_command build_command resource, :delete
      rescue Exception => e
        Chef::Log.error("Could not delete meter [#{resource.name}], failed with #{e}")
      end
    end

    # TODO rethink this. This should be handled elsewhere
    def collect_tags
      tags = []

      # Chef Tags
      node['boundary_meter']['tags'].each do |tag|
        tags.push tag
      end

      # EC2 Tags
      if node['ec2']
        node['ec2']['security_groups'].each do |group|
          tags.push group
        end

        if node['ec2']['placement_availability_zone']
          tags.push node['ec2']['placement_availability_zone']
        end

        if node['ec2']['instance_type']
          tags.push node['ec2']['instance_type']
        end
      end

      # OPSWorks Tags
      if node['opsworks']
        if node['opsworks']['stack']
          if node['opsworks']['stack']['name']
            tags.push node['opsworks']['stack']['name']
          end
        end

        if node['opsworks']['instance']
          node['opsworks']['instance']['layers'].each do |layer|
            tags.push layer
          end
        end

        node['opsworks']['applications'].each do |app|
          tags.push app['name']
          tags.push app['application_type']
        end
      end

      return tags.join(',')
    end
  end

  class DataBag
    attr_accessor :node

    def initialize(node)
      @node = node
    end

    def exists?(resource)
      if Chef::DataBag.list.key?("#{resource.databag_name}")
        Chef::Log.info("Databag [#{resource.databag_name}] found on Chef server.")
        return true
      else
        Chef::Log.info("Databag [#{resource.databag_name}] not found on Chef server.")
        return false
      end
    end

    def merge(resource)
      begin
          data = Chef::DataBagItem.load("#{resource.databag_name}", "#{resource.databag_item}").raw_data
          Chef::Log.info("Loaded DataBag #{resource.databag_name}")
          data.delete('id')
          Chef::Mixin::DeepMerge.deep_merge!(data, node.default)
      rescue Exception => e
        Chef::Log.error("Could not merge databag  [#{resource.databag_name}/#{resource.databag_item}], failed with #{e}")
      end
    end
  end

end
