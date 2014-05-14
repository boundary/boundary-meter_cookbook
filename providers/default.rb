#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Provider:: default
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

action :create do
  if meter_exists?(new_resource)
    Chef::Log.debug('Boundary meter already exists, not creating.')
  else
    create_meter(new_resource)
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  if meter_exists?(new_resource)
    delete_meter_request(new_resource)
  else
    Chef::Log.debug("Boundary meter doesn't exist, not deleting.")
  end

  new_resource.updated_by_last_action(true)
end

private

def create_meter(resource)
  create_meter_request(resource)

  apply_cloud_tags(resource)
  apply_meter_tags(resource)
  node.roles.each do |role|
    apply_an_tag(resource, role)
  end

  apply_an_tag(resource, node.chef_environment)
end
