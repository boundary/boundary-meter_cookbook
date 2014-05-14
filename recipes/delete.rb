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

meter_name = node['boundary_meter']['hostname']

# delete the cert and key files on disk
boundary_meter_certificates meter_name do
  action :delete
end

# delete the meter from the boundary api
boundary_meter meter_name do
  action :delete
end

service 'boundary-meter' do
  action [ :stop, :disable ]
end

package 'boundary-meter' do
  action :remove
end
