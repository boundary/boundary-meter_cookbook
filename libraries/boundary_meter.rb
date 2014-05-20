#
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Cookbook Name:: boundary-meter
# Library:: boundary_meter
#
# Copyright 2011, Boundary
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
  module Meter
    def setup_conf_dir(resource)
      Dir.mkdir(resource.target_dir) unless ::Dir.exists?(resource.target_dir)
      ::File.cp '/etc/boundary/ca.pem', "#{resource.target_dir}/" unless ::File.exists?("#{resource.target_dir}/ca.pem")
    end

    def remove_conf_dir(resource)
      if ::Dir.exists?(resource.target_dir) && resource.target_dir != '/etc/boundary' && resource.target_dir.include?('/etc/boundary')
        ::FileUtils.rm Dir.glob "#{resource.target_dir}/*"
        ::Dir.rmdir resource.target_dir         
      end
    end

    def build_command(resource, action)
      command = [
        "boundary-meter -l #{action.to_s}",
        "-L https://#{node['boundary_meter']['api']['hostname']}",
        "-p #{node['boundary_meter']['org_id']}:#{node['boundary_meter']['api_key']}",
        "-b #{resource.target_dir}",
        "-n tls://#{node['boundary_meter']['collector']['hostname']}:#{node['boundary_meter']['collector']['port']}",
        "--nodename #{resource.name}"
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

      system command

      raise Exception.new("Command Failed") unless $? == 0
    end

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

        if node[:ec2][:instance_type]
          tags.push node[:ec2][:instance_type]
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
end
