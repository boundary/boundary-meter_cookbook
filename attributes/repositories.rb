#
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: boundary-meter
# Attributes:: repositories
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

default['boundary_meter']['repositories']['apt']['url'] = 'https://apt.boundary.com/ubuntu/'
default['boundary_meter']['repositories']['apt']['key'] = 'https://apt.boundary.com/APT-GPG-KEY-Boundary'

default['boundary_meter']['repositories']['yum']['url'] = 'https://yum.boundary.com/centos/os'
default['boundary_meter']['repositories']['yum']['key'] = 'https://yum.boundary.com/RPM-GPG-KEY-Boundary'
