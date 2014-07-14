#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Resource:: default
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

actions :create, :delete
default_action :create if defined?(default_action)

def initialize(*args)
  super
  @action = :create
end

def conf_dir( arg=nil )
  if arg.nil? and @conf_dir.nil? and is_alt == true
    "%s_%s" % [Boundary::Meter::CONF_DIR, name]
  elsif arg.nil? and @conf_dir.nil? and is_alt == false
  	Boundary::Meter::CONF_DIR
  else
    set_or_return( :conf_dir, arg, :kind_of => String )
  end
end

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :node_name, :kind_of => String, :required => true
attribute :org_id, :kind_of => String, :required => true
attribute :api_key, :kind_of => String, :required => true
attribute :is_alt, :kind_of => [TrueClass, FalseClass], :default => false
