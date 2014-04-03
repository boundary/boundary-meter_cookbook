#
# Author:: Ben Black (<b@boundary.com>)
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: bprobe
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

include_recipe 'bprobe::dependencies'

package 'bprobe'

meter_name = node['boundary_meter']['hostname']

bprobe meter_name do
  org_id node['boundary_meter']['org_id']
  api_key node['boundary_meter']['api_key']
end

directory '/etc/bprobe' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

bprobe_certificates meter_name do
  org_id node['boundary_meter']['org_id']
  api_key node['boundary_meter']['api_key']
end

service 'bprobe'

cookbook_file '/etc/bprobe/ca.pem' do
  source 'ca.pem'
  owner 'root'
  group 'root'
  mode '0600'
  notifies :restart, resources(:service => 'bprobe')
end

node['boundary_meter']['alt_configs'].each do |config|
  config_dir = "/etc/bprobe_#{config['name']}"

  bprobe meter_name do
    org_id config['org_id']
    api_key config['api_key']
  end

  directory config_dir do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  bprobe_certificates meter_name do
    org_id config['org_id']
    api_key config['api_key']
  end

  cookbook_file "#{config_dir}/ca.pem" do
    source 'ca.pem'
    owner 'root'
    group 'root'
    mode '0600'
    notifies :restart, resources(:service => 'bprobe')
  end
end

template '/etc/default/bprobe' do
  source 'bprobe.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources(:service => 'bprobe')
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
