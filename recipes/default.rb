#
# Author:: Ben Black (<b@boundary.com>)
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Recipe:: default
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

include_recipe 'boundary-meter::dependencies'

package 'boundary-meter' do
  action boundary_data('install_type').to_sym
end

service 'boundary-meter' do
  ignore_failure true
end

boundary_meter "default" do
  notifies :restart, "service[boundary-meter]"
  ignore_failure true
end

boundary_data('alt_configs').each do |config|
  boundary_meter config['name'] do
    token config['token']
    is_alt true
    notifies :restart, "service[boundary-meter]"
    ignore_failure true
  end
end

template '/etc/default/boundary-meter' do
  source 'boundary-meter.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[boundary-meter]"
  variables :boundary_meter => boundary_data_merge
end
