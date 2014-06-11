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
  case node['kernel']['machine']
  # There are no i686 meter builds
  when 'i686', 'i386'
    machine = 'i386'
  else
    machine = 'x86_64'
  end

  yum_repository 'boundary' do
    description 'boundary'
    baseurl "#{node['boundary_meter']['repositories']['yum']['url']}/#{machine}/"
    gpgkey node['boundary_meter']['repositories']['yum']['key']
    action :create
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
