#
# Cookbook Name:: hadoop_mapr_wrapper
# Recipe:: configure
#
# Copyright © 2013-2015 Cask Data, Inc.
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

# Ensure configure.sh script is installed
include_recipe 'hadoop_mapr::warden'

# Unmount data disks
node['hadoop_mapr']['configure_sh']['args'].each do |k, v|
  next unless k == '-D'
  chef::Application.fatal!('The -D argument for configure_sh requires a value') if v.nil?
  v.split(',').each do |disk|
    next if disk.nil?

    # Chef mount resource requires the mount_point as well
    mount_cmd = Mixlib::ShellOut.new('mount')
    mount_cmd.run_command
    mount_cmd.stdout.each_line do |line|
      next unless line =~ /^#{disk}\son\s/
      current_mount_point = line.split(' ')[2]

      # unmount this disk
      mount current_mount_point do
        device disk
        action [:umount, :disable]
      end
    end
  end
end

# Collect additional arguments for configure.sh
lwrp_args = []

# Translate relevant hadoop attributes into configure.sh args (-RM, -HS)
if node['hadoop'].key?('mapred_site') && node['hadoop']['mapred_site'].key?('mapreduce.jobhistory.address')
    lwrp_args.push('-HS' => node['hadoop']['mapred_site']['mapreduce.jobhistory.address']
end
if node['hadoop'].key?('yarn_site') && node['hadoop']['yarn_site'].key?('yarn.resourcemanager.hostname')
  lwrp_args.push('-RM' => node['hadoop']['yarn_site']['yarn.resourcemanager.hostname']
end

node['hadoop_mapr']['configure_sh']['args'].each do |k, v|
  if v.nil?
    # pass a flag, prevent duplicates
    next if lwrp_args.include?(k)
    lwrp_args.push(k)
  else
    # pass a key/value, prevent duplicates
    next if lwrp_args.map{|x| x.keys if x.is_a? Hash}.flatten.include?(k)
    lwrp_args.push(k => v)
  end
end

# Ensure cluster_name is not nil
unless node['hadoop_mapr'].key?('configure_sh') && node['hadoop_mapr']['configure_sh'].key?('cluster_name') && !node['hadoop_mapr']['configure_sh']['cluster_name'].nil?
  Chef::Application.fatal!("node['hadoop_mapr']['configure_sh']['cluster_name'] cannot be nil")
end

# Invoke configure.sh
hadoop_mapr_configure node['hadoop_mapr']['configure_sh']['cluster_name'] do
  cldb_list node['hadoop_mapr']['configure_sh']['cldb_list']
  zookeeper_list node['hadoop_mapr']['configure_sh']['zookeeper_list']
  cldb_mh_list node['hadoop_mapr']['configure_sh']['cldb_mh_list']
  refresh_roles node['hadoop_mapr']['configure_sh']['refresh_roles']
  client_only_mode node['hadoop_mapr']['configure_sh']['client_only_mode']
  args lwrp_args
  action :run
end

# configure.sh blows away any custom yarn configs
include_recipe 'hadoop_mapr::hadoop_yarn' if (node['hadoop'].key?('yarn_site') && !node['hadoop']['yarn_site'].empty?) || (node['hadoop'].key?('yarn_site') && !node['hadoop']['mapred_site'].empty?)
include_recipe 'hadoop_mapr::hbase' if node['hbase'].key?('hbase_site') && !node['hbase']['hbase_site'].empty?
include_recipe 'hadoop_mapr::hive' if node['hive'].key?('hive_site') && !node['hive']['hive_site'].empty?
