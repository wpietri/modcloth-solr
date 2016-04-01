require 'spec_helper.rb'
describe 'modcloth-solr::user' do
  context 'When all attributes are default on unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
      end.converge(described_recipe)
    end

    it 'Adds user solr' do
      expect(chef_run).to create_user('solr')
    end
  end
end
