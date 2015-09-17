name             'hadoop_mapr_wrapper'
maintainer       'Cask Data, Inc.'
maintainer_email 'ops@cask.co'
license          'Apache 2.0'
description      'Wrapper cookbook for caskdata/hadoop_mapr_cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'hadoop_mapr'

%w(amazon centos debian redhat scientific ubuntu).each do |os|
  supports os
end
