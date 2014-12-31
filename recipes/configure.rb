#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Recipe:: delete
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

databag = node['boundary_meter']['data_bag']

boundary_meter_databag_merge "#{databag['name']}" do
  databag_name databag['name']
  databag_item databag['item']
  action :merge
  only_if {databag['merge'] }
end

service 'boundary-meter'

meter_name = node['boundary_meter']['hostname']

node['boundary_meter']['alt_configs'].each do |config|
  boundary_meter config['name'] do
    node_name meter_name
    token config['token']
    is_alt true
    action :configure
    #notifies :restart, "service[boundary-meter]"
  end
end

boundary_meter "default" do
  node_name meter_name
  token node['boundary_meter']['token']
  action :configure
  #notifies :restart, "service[boundary-meter]"
end

