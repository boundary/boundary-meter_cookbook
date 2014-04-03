#
# Author:: Joe Williams (<j@boundary.com>)
# Author:: Scott Smith (<scott@boundary.com>)
# Cookbook Name:: bprobe
# Attributes:: default
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

default['boundary_meter']['org_id'] = ''
default['boundary_meter']['api_key'] = ''
default['boundary_meter']['hostname'] = node['fqdn']
default['boundary_meter']['tags'] = [node.chef_environment]

# alertnate configurations for multiplexing meter traffic
# see https://app.boundary.com/docs/meter/2_0_3
default['boundary_meter']['alt_configs'] = []

# explicity list interfaces to monitor (you can leave this empty)
default['boundary_meter']['interfaces'] = []

# periodic stats on pcap interface
default['boundary_meter']['pcap_stats'] = 0

# promisc mode
default['boundary_meter']['pcap_promisc'] = 0

# STUN support for public IP detection
default['boundary_meter']['enable_stun'] = 0

#
# you should not have to modify these values
#
default['boundary_meter']['api']['hostname'] = 'api.boundary.com'
default['boundary_meter']['collector']['hostname'] = 'collector.boundary.com'
default['boundary_meter']['collector']['port'] = 4740
