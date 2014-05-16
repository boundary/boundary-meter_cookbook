#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Recipe:: dependencies
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

case node['platform_family']
when 'rhel'
  # default to 64bit
  machine = 'x86_64'

  case node['kernel']['machine']
  when 'x86_64'
    machine = 'x86_64'
  when 'i686'
    machine = 'i386'
  when 'i386'
    machine = 'i386'
  end

  rhel_platform_version = node['platform'] == 'amazon' ? '6' : node['platform_version']

  yum_repository 'boundary' do
    description 'boundary'
    url "#{node['boundary_meter']['repositories']['yum']['url']}/#{machine}/"
    gpgkey node['boundary_meter']['repositories']['yum']['key']
    action :create
  end

  ruby_block 'reload-internal-yum-cache' do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
  end
when 'debian', 'ubuntu'
  package 'apt-transport-https'

  apt_repository 'boundary' do
    uri node['boundary_meter']['repositories']['apt']['url']
    distribution node['lsb']['codename']
    components ['universe']
    key node['boundary_meter']['repositories']['apt']['key']
  end
end

cookbook_file "#{Chef::Config[:file_cache_path]}/cacert.pem" do
  source "cacert.pem"
  mode 0600
  owner "root"
  group "root"
end
