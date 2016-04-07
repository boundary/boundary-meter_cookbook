#
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Cookbook Name:: boundary-meter
# Library:: boundary_meter
#
# Copyright 2015, Boundary
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

# TODO move use of boundary_data out of this module (thinking)

module Boundary
  module Meter

    CONF_DIR = '/etc/boundary'

    def get_meter(resource)
      meter_name = (resource.is_alt) ? "boundary-meter_#{resource.name}" : 'boundary-meter'
      cmd = Mixlib::ShellOut.new("boundary-meter --dump-meter-info -I #{meter_name}")
      cmd.run_command
      raise Exception.new("boundary meter status failed") if cmd.error?
      json = JSON.parse(cmd.stdout)
    end

    def meter_provisioned?(resource)
      meter = get_meter(resource)
      meter['status']['premium'] == 'ok' or meter['status']['enterprise'] == 'ok'
    end

    # TODO This is transitional
    # Only checking a subset of values relevent to provisioning
    def meter_config_current?(resource)
      return false unless ::File.exists?("#{resource.conf_dir}/meter.conf")

      config = JSON.parse(::File.read("#{resource.conf_dir}/meter.conf"))
      
      # No elegant way to do this.
      tokens = resource.token.split(',')
      raise Exception.new("invalid number of tokens specified") if tokens.size > 2

      enterprise_token = tokens.select{|tok| tok.include?(':')}.first.to_s
      premium_token = tokens.select{|tok| tok.include?('api.') || tok.include?('-')}.first.to_s

      return false unless 
        premium_token == config['premium_api']['token'] and
        (enterprise_token == "#{config['enterprise_api']['org_id']}:#{config['enterprise_api']['api_key']}" or enterprise_token.empty?) and
        boundary_data('premium_api')['hostname'] == config['premium_api']['host'] and
        boundary_data('api')['hostname'] == config['enterprise_api']['host'] and
        "tls://#{boundary_data('collector')['hostname']}:#{boundary_data('collector')['port']}" == config['collector']['collectors'][0]

      true        
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
        "-L https://#{boundary_data('api')['hostname']}",
        "-P https://#{boundary_data('premium_api')['hostname']}",
        "-p #{resource.token}",
        "-b #{resource.conf_dir}",
        "-n tls://#{boundary_data('collector')['hostname']}:#{boundary_data('collector')['port']}",
        "--nodename #{resource.node_name}"
      ]

      if action == :create
        command.push "--tag #{resource.tags.join(',')}" unless resource.tags.empty?

        if boundary_data('enable_stun') == 1
          command.push "--enable-stun"
        end

        if boundary_data('tls')['skip_validation'] == true
          command.push "--tls-skip-validation"
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
  end
end
