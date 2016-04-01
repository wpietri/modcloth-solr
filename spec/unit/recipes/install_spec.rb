require 'spec_helper.rb'

describe 'modcloth-solr::install' do

  context 'When all attributes are default on unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
      end.converge(described_recipe)
    end

    it 'Retrieves remote file apache-solr-3.6.0.tgz' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/apache-solr-3.6.0.tgz")
    end

    it 'untars the downloaded apache-solr archive' do
      expect(chef_run).to run_execute("cd #{Chef::Config[:file_cache_path]} && tar -xvf #{Chef::Config[:file_cache_path]}/apache-solr-3.6.0.tgz")
    end

    it 'creates the solr directory /opt/solr-3.6.0' do
      expect(chef_run).to create_directory('/opt/solr-3.6.0')
    end

    ### Skipping tests for the ruby_blocks to copy the directories around (for now)
    it 'executes a ruby block to create an empty directory' do
      expect(chef_run).to run_ruby_block('create empty data directory')
    end

    it 'executes a ruby block to copy the example solr directory' do
      expect(chef_run).to run_ruby_block('copy example solr home directory')
    end

    ### This is a test for a resource that is not idempotent.   The resource should be fixed.
    it 'chowns the solr directory' do
      expect(chef_run).to run_execute('chown solr directory')
    end

    it 'creates a symlink from the versioned solr dir to /opt/solr' do
      expect(chef_run).to create_link('/opt/solr').with(to: '/opt/solr-3.6.0')
    end

    it 'creates the solr log directory /var/log/solr' do
      expect(chef_run).to create_directory('/var/log/solr')
    end

  end

end