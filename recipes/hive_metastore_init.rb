#
# Cookbook Name:: hadoop_mapr_wrapper
# Recipe:: hive_metastore_init
#
# Copyright © 2015 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'hadoop_mapr::default'
include_recipe 'hadoop_mapr::hive_metastore'

ruby_block 'initaction-create-hive-mfs-warehousedir' do
  block do
    resources('execute[hive-mfs-warehousedir]').run_action(:run)
  end
end

scratch_dir =
  if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.exec.scratchdir')
    node['hive']['hive_site']['hive.exec.scratchdir']
  else
    '/tmp/hive-${user.name}'
  end

ruby_block 'initaction-create-hive-mfs-scratchdir' do
  block do
    resources('execute[hive-mfs-scratchdir]').run_action(:run)
  end
  not_if { scratch_dir == '/tmp/hive-${user.name}' }
end
