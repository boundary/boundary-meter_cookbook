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

default['bprobe']['meter']['org_id'] = ''
default['bprobe']['meter']['api_key'] = ''
default['bprobe']['meter']['hostname'] = node['fqdn']
default['bprobe']['meter']['tags'] = [node.chef_environment]

# alertnate configurations for multiplexing meter traffic
# see https://app.boundary.com/docs/meter/2_0_3
default['bprobe']['meter']['alt_configs'] = []

# explicity list interfaces to monitor (you can leave this empty)
default['bprobe']['meter']['interfaces'] = []

# periodic stats on pcap interface
default['bprobe']['meter']['pcap_stats'] = 0

# promisc mode
default['bprobe']['meter']['pcap_promisc'] = 0

# STUN support for public IP detection
default['bprobe']['meter']['enable_stun'] = 0

#
# you should not have to modify these values
#
default['bprobe']['api']['hostname'] = 'api.boundary.com'
default['bprobe']['collector']['hostname'] = 'collector.boundary.com'
default['bprobe']['collector']['port'] = 4740
