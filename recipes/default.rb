#
# Author:: Ben Black (<b@boundary.com>)
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Recipe:: default
#
# Copyright 2010, Boundary
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

include_recipe 'boundary-meter::dependencies'

package 'boundary-meter' do
  action node['boundary_meter']['install_type'].to_sym
end

service 'boundary-meter'

meter_name = node['boundary_meter']['hostname']

boundary_meter "default" do
  node_name meter_name
  org_id node['boundary_meter']['org_id']
  api_key node['boundary_meter']['api_key']
  notifies :restart, resources(:service => 'boundary-meter')
end

node['boundary_meter']['alt_configs'].each do |config|
  boundary_meter "#{config['name']}" do
    node_name meter_name
    org_id config['org_id']
    api_key config['api_key']
    is_alt true
    notifies :restart, resources(:service => 'boundary-meter')
  end
end

template '/etc/default/boundary-meter' do
  source 'boundary-meter.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'boundary-meter')
  variables({
              :collector_uri => "tls://#{node['boundary_meter']['collector']['hostname']}:#{node['boundary_meter']['collector']['port']}",
              :interfaces => node['boundary_meter']['interfaces'],
              :pcap_stats => node['boundary_meter']['pcap_stats'],
              :pcap_promisc => node['boundary_meter']['pcap_promisc'],
              :disable_ntp => node['boundary_meter']['disable_ntp'],
              :enable_stun => node['boundary_meter']['enable_stun'],
              :alt_configs => node['boundary_meter']['alt_configs'].collect {|cfg| cfg['name']}
            })
end
