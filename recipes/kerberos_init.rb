#
# Cookbook Name:: hadoop_wrapper
# Recipe:: kerberos_init
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

# Enable kerberos security
if node['hadoop'].key?('core_site') && node['hadoop']['core_site'].key?('hadoop.security.authorization') &&
   node['hadoop']['core_site'].key?('hadoop.security.authentication') &&
   node['hadoop']['core_site']['hadoop.security.authorization'].to_s == 'true' &&
   node['hadoop']['core_site']['hadoop.security.authentication'] == 'kerberos'

  # include_recipe 'krb5'
  Chef::Log.info("Secure Hadoop Enabled: Kerberos Realm '#{node['krb5']['krb5_conf']['realms']['default_realm']}'")
  secure_hadoop_enabled = true

  # Create users for services not in base Hadoop
  %w(hbase hive spark zookeeper).each do |u|
    user u do
      action :create
    end
  end

  include_recipe 'krb5_utils'
  # Hack up /etc/default/hadoop-hdfs-datanode
  execute 'modify-etc-default-files' do
    command 'sed -i -e "/HADOOP_SECURE_DN/ s/^#//g" /etc/default/hadoop-mapr-datanode'
    only_if 'test -e /etc/default/hadoop-mapr-datanode'
  end
  # We need to kinit as hdfs to create directories
  execute 'kinit-as-mapr-user' do
    command "kinit -kt #{node['krb5_utils']['keytabs_dir']}/mapr.service.keytab mapr/#{node['fqdn']}@#{node['krb5']['krb5_conf']['realms']['default_realm'].upcase}"
    user 'mapr'
    group 'mapr'
    only_if "test -e #{node['krb5_utils']['keytabs_dir']}/mapr.service.keytab"
  end
end

if node['hbase'].key?('hbase_site') && node['hbase']['hbase_site'].key?('hbase.security.authorization') &&
   node['hbase']['hbase_site'].key?('hbase.security.authentication') &&
   node['hbase']['hbase_site']['hbase.security.authorization'].to_s == 'true' &&
   node['hbase']['hbase_site']['hbase.security.authentication'] == 'kerberos'

  if secure_hadoop_enabled.nil?
    Chef::Application.fatal!('You must enable kerberos in Hadoop or disable kerberos for HBase!')
  end
end

bash "insert_line" do
  user "root"
  code <<-EOS
  echo '' >> /opt/mapr/conf/env.sh
  echo '#**** Added by Chef ****' >> /opt/mapr/conf/env.sh
  echo 'export MAPR_HIVE_LOGIN_OPTS="${MAPR_HIVE_LOGIN_OPTS} -Dhadoop.login=hybrid"' >> /opt/mapr/conf/env.sh
  echo 'export MAPR_HIVE_SERVER_LOGIN_OPTS="${MAPR_HIVE_SERVER_LOGIN_OPTS} -Dhadoop.login=hybrid"' >> /opt/mapr/conf/env.sh
  echo 'export MAPR_HBASE_CLIENT_OPTS="${HYBRID_LOGIN_OPTS}"' >> /opt/mapr/conf/env.sh
  echo 'export MAPR_HBASE_SERVER_OPTS="${KERBEROS_LOGIN_OPTS} ${MAPR_SSL_OPTS} -Dmapr.library.flatclass"' >> /opt/mapr/conf/env.sh
  cp /etc/security/keytabs/mapr.service.keytab /opt/mapr/conf/mapr.keytab
  EOS
  #not_if "grep -q www.example.com /opt/mapr/conf/env.sh"
end

template '/opt/mapr/conf/mapr.login.conf' do
  source 'mapr.login.conf.erb'
  owner 'mapr'
  group 'mapr'
  mode 0755
end

if node['hive'].key?('hive_site') && node['hive']['hive_site'].key?('hive.metastore.sasl.enabled') &&
   node['hive']['hive_site']['hive.metastore.sasl.enabled'].to_s == 'true'

  if secure_hadoop_enabled.nil?
    Chef::Application.fatal!('You must enable kerberos in Hadoop or disable kerberos for Hive!')
  end
end
