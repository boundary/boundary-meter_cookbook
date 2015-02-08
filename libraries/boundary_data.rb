#
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Cookbook Name:: boundary-meter
# Library:: boundary_data
#
# Copyright 2015, Boundary
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

# TODO Having to do this just to do basic data access indirection involving
# node attrs and databag values is crap. Redo this, even if it mean accessing
# primitives, when there is more time.

class Chef
  module DSL::DataQuery
    def boundary_data(value, namespace='boundary_meter')
      from_data_bag(value, namespace) ||
      from_node_attr(value, namespace)
    end

    def boundary_data_merge(namespace='boundary_meter')
      databag, item = namespace.split('_')
      return node[namespace] unless data_bag(databag).include?(item)
      node[namespace].merge(data_bag_item(databag, item).to_hash)
    end

    private

    def from_data_bag(value, namespace)
      databag, item = namespace.split('_')
      
      if data_bag(databag).include?(item)
        return data_bag_item(databag, item)[value]
      end

      nil
    end

    def from_node_attr(value, namespace)
      return node[namespace][value]
    end
  end
end
