require 'spec_helper.rb'

describe 'modcloth-solr::master' do

  before do
    stub_command('id -u ecomm').and_return('111')
  end

  context 'When all attributes are default on unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
      end.converge(described_recipe)
    end

    it 'Renders template solr-master-log.conf' do
      expect(chef_run).to render_file('/opt/solr/master/log.conf')
    end

    it 'Renders template solrconfig.xml' do
      expect(chef_run).to render_file('/opt/solr/master/solr/conf/solrconfig.xml')
    end

    it 'Renders template schema.xml' do
      expect(chef_run).to render_file('/opt/solr/master/solr/conf/schema.xml')
    end

    ### I'm not sure how to add examples for the smf items.

    ### Also not sure how to mock this up so that it tests for both possibilites.
    ### I want to run this as the default (true) and then also as false.

    it 'Enables the rmiregistry service' do
      expect(chef_run).to enable_service('rmiregistry')
    end

    it 'Enables the solr-master service' do
      expect(chef_run).to enable_service('solr-master')
    end

  end

end