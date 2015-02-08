#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Cookbook Name:: boundary-meter
# Provider:: default
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

include Boundary::Meter

action :create do
  if meter_exists?(new_resource)
    new_resource.updated_by_last_action(false)
  else
    create_meter new_resource
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if meter_exists?(new_resource)
    delete_meter new_resource
    new_resource.updated_by_last_action(true)
  else
    new_resource.updated_by_last_action(false)
  end
end

private

def meter_exists?(resource)
  # If meter is running but is an unprovisioned state return false
  meter_config_current?(resource) and
	meter_provisioned?(resource)
end

def create_meter(resource)
  setup_conf_dir resource

  Chef::Log.info("Creating meter [#{resource.name}]")

  begin
    run_command build_command resource, :create
  rescue Exception => e
    Chef::Log.error("Could not create meter [#{resource.name}], failed with #{e}")
  end
end

def delete_meter(resource)
  remove_conf_dir resource

  Chef::Log.info("Deleting meter [#{resource.name}]")

  begin
    run_command build_command resource, :delete
  rescue Exception => e
    Chef::Log.error("Could not delete meter [#{resource.name}], failed with #{e}")
  end
end
