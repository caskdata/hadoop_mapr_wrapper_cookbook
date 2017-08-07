name             'hadoop_mapr_wrapper'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache 2.0'
description      'Wrapper cookbook for caskdata/hadoop_mapr_cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends 'hadoop_mapr'

depends 'mysql', '~> 8.0'
depends 'database', '~> 6.0'
depends 'mysql2_chef_gem'

%w(amazon centos debian redhat scientific ubuntu).each do |os|
  supports os
end
