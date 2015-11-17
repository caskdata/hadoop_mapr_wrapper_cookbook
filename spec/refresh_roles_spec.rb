require 'spec_helper'

describe 'hadoop_mapr_wrapper::refresh_roles' do
  context 'on Centos 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        node.override['hadoop_mapr']['configure_sh']['cluster_name'] = 'test_cluster'
      end.converge(described_recipe)
    end

    it 'does nothing if cluster not found' do
      stub_command(/grep /).and_return(false)
      resource = chef_run.hadoop_mapr_configure('test_cluster')
      expect(resource).to do_nothing
    end

    it 'runs configure lwrp' do
      stub_command(/grep /).and_return(true)
      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_refresh_roles(true)
    end
  end
end
