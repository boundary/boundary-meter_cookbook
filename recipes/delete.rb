#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Recipe:: delete
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

service 'boundary-meter' do
  action [ :stop, :disable ]
end

meter_name = node['boundary_meter']['hostname']

node['boundary_meter']['alt_configs'].each do |config|
  boundary_meter "#{config['name']}" do
    node_name meter_name
    org_id config['org_id']
    api_key config['api_key']
    is_alt true
    action :delete
  end
end

boundary_meter "default" do
  node_name meter_name
  org_id node['boundary_meter']['org_id']
  api_key node['boundary_meter']['api_key']
  action :delete
end

package 'boundary-meter' do
  action :purge
end
