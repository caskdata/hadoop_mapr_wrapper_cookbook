require 'spec_helper'

describe 'hadoop_mapr_wrapper::hive_metastore_db_init' do
  context 'on Centos 6.6' do
    before do
      allow_any_instance_of(HadoopMapr::Helpers).to receive(:hive_conf_dir).and_return('/some/dir')
    end
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hive']['hive_site']['hive.metastore.uris'] = 'thrift://fauxhai.local:9083'
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionURL'] = 'jdbc:mysql://localhost:3306/hive'
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionDriverName'] = 'com.mysql.jdbc.Driver'
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionUserName'] = 'user'
        node.override['hive']['hive_site']['javax.jdo.option.ConnectionPassword'] = 'password'
      end.converge(described_recipe)
    end

    # ChefSpec matchers introduced in database v2.1.8
    # it 'creates a database' do
    #   expect(chef_run).to create_database('hive')
    # end
  end
end
