#
# Cookbook Name:: boundary-meter
# Resource:: default
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

actions :merge
default_action :merge if defined?(default_action)

def initialize(*args)
  super
  @action = :merge
end

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :databag_name, :kind_of => String, :required => true
attribute :databag_item, :kind_of => String, :required => true
