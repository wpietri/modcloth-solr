require 'spec_helper.rb'

describe 'modcloth-solr::install_newrelic' do
  context 'When all attributes are default on unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set['solr']['newrelic']['jar'] = '/opt/solr/newrelic/newrelic.jar'
        node.set['solr']['newrelic']['api_key'] = 'keykeykey'
      end.converge(described_recipe)
    end

    it 'creates the newrelic directory /opt/solr/newrelic' do
      expect(chef_run).to create_directory('/opt/solr/newrelic')
    end

    it 'creates remote file /opt/solr/newrelic/newrelic.jar' do
      expect(chef_run).to create_remote_file('/opt/solr/newrelic/newrelic.jar')
    end

    it 'renders /opt/solr/newrelic/newrelic.yml template' do
      expect(chef_run).to render_file('/opt/solr/newrelic/newrelic.yml')
    end
  end
end
