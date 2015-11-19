require 'spec_helper'

describe 'hadoop_mapr_wrapper::hive_metastore_init' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6).converge(described_recipe)
    end

    it 'does not run initaction-create-hive-mfs-scratchdir ruby_block' do
      expect(chef_run).not_to run_ruby_block('initaction-create-hive-mfs-scratchdir')
    end

    it 'runs initaction-create-hive-mfs-warehousedir ruby_block' do
      expect(chef_run).to run_ruby_block('initaction-create-hive-mfs-warehousedir')
    end
  end

  context 'using custom hive.exec.scratchdir' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hive']['hive_site']['hive.exec.scratchdir'] = '/some/path'
      end.converge(described_recipe)
    end

    it 'runs initaction-create-hive-mfs-scratchdir ruby_block' do
      expect(chef_run).to run_ruby_block('initaction-create-hive-mfs-scratchdir')
    end
  end
end
