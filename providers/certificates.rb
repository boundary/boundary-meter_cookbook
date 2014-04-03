#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: bprobe
# Provider:: certificates
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

include Boundary::API

action :install do
  meter_dir = meter_directory(new_resource)

  if meter_dir
    download_certificate_request(new_resource, meter_dir)
    download_key_request(new_resource, meter_dir)
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  meter_dir = meter_directory(new_resource)

  if meter_dir
    [ "#{meter_dir}/cert.pem",
      "#{meter_dir}/key.pem"
    ].each do |file|
      file file do
        action :delete
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

private

def meter_directory(new_resource)
  dir_prefix = "/etc/bprobe"
  dir_path = nil

  if node['boundary_meter']['org_id'] == new_resource.org_id
    dir_path = dir_prefix
  else
    found = node['boundary_meter']['alt_configs'].detect {|meter| meter['org_id'] == new_resource.org_id }

    if found
      dir_path = "#{dir_prefix}_#{found['name']}"
    end
  end

  return dir_path
end

def download_certificate_request(new_resource, path)
  if ::File.exist?("#{path}/cert.pem")
    Chef::Log.debug('Certificate file already exists, not downloading.')
  else
    begin
      auth = auth_encode(new_resource.api_key)
      base_url = build_url(new_resource, :certificates)
      headers = {"Authorization" => "Basic #{auth}"}
      cert_response = http_request(:get, "#{base_url}/cert.pem", headers)

      if cert_response
        file "#{path}/cert.pem" do
          owner 'root'
          group 'root'
          mode '0600'
          content cert_response.body
          notifies :restart, resources(:service => 'bprobe')
        end
      else
        Chef::Log.error('Could not download certificate (nil response)!')
      end
    rescue Exception => e
      Chef::Log.error("Could not download certificate, failed with #{e}")
    end
  end
end

def download_key_request(new_resource, path)
  if ::File.exist?("#{path}/key.pem")
    Chef::Log.debug('Key file already exists, not downloading.')
  else
    begin
      auth = auth_encode(new_resource.api_key)
      base_url = build_url(new_resource, :certificates)
      headers = {"Authorization" => "Basic #{auth}"}
      key_response = http_request(:get, "#{base_url}/key.pem", headers)

      if key_response
        file "#{path}/key.pem" do
          owner 'root'
          group 'root'
          mode '0600'
          content key_response.body
          notifies :restart, resources(:service => 'bprobe')
        end
      else
        Chef::Log.error('Could not download key (nil response)!')
      end
    rescue Exception => e
      Chef::Log.error("Could not download key, failed with #{e}")
    end
  end
end
