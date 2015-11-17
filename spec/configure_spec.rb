require 'spec_helper'

describe 'hadoop_mapr_wrapper::configure' do
  context 'on Centos 6.6' do
    let(:shellout) { double('shellout') }
    before { allow(Mixlib::ShellOut).to receive(:new).and_return(shellout, run_command: nil) }
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.6) do |node|
        # LWRP direct attributes
        node.override['hadoop_mapr']['configure_sh']['cluster_name'] = 'test_cluster'
        node.override['hadoop_mapr']['configure_sh']['cldb_list'] = ['cldbhost']
        node.override['hadoop_mapr']['configure_sh']['zookeeper_list'] = ['zoohost']
        # These get converted to LWRP args attribute
        node.override['hadoop_mapr']['mapr_user']['username'] = 'testuser'
        node.override['hadoop_mapr']['mapr_user']['group'] = 'testgroup'
        node.override['hadoop']['mapred_site']['mapreduce.jobhistory.address'] = 'hs_host'
        node.override['hadoop']['yarn_site']['yarn.resourcemanager.hostname'] = 'rm_host'
        # Additional LWRP args
        node.override['hadoop_mapr']['configure_sh']['args']['-D'] = '/dev/sdc'
        node.override['hadoop_mapr']['configure_sh']['args']['-noval'] = nil
        # Mock disk to unmount
        expect(shellout).to receive(:run_command).and_return(true)
        expect(shellout).to receive(:stdout).and_return('/dev/sdc on /mountpoint type ext4 (rw)')
      end.converge(described_recipe)
    end

    it 'includes warden recipe' do
      expect(chef_run).to include_recipe('hadoop_mapr::warden')
    end

    it 'unmounts a mounted disk' do
      expect(chef_run).to umount_mount('/dev/sdc')
      expect(chef_run).to disable_mount('/dev/sdc')
    end

    it 'runs configure lwrp with attributes' do
      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_cldb_list(['cldbhost'])
      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_zookeeper_list(['zoohost'])
      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_refresh_roles(false)
      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_client_only_mode(false)
      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_no_autostart(true)
    end

    it 'runs configure lwrp with the correct additional args' do
      expected_args = []
      expected_args.push('-HS' => 'hs_host')
      expected_args.push('-RM' => 'rm_host')
      expected_args.push('-u' => 'testuser')
      expected_args.push('-g' => 'testgroup')
      expected_args.push('-D' => '/dev/sdc')
      expected_args.push('-noval')

      expect(chef_run).to run_hadoop_mapr_configure('test_cluster').with_args(expected_args)
    end

    it 'includes configuration recipes' do
      expect(chef_run).to include_recipe('hadoop_mapr::hadoop_yarn')
      expect(chef_run).to include_recipe('hadoop_mapr::hbase')
      expect(chef_run).to include_recipe('hadoop_mapr::hive')
    end
  end
end
