require 'spec_helper.rb'
describe 'modcloth-solr::default' do
  before do
    stub_command('id -u ecomm').and_return('111')
  end

  context 'When all attributes are default on unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
      end.converge(described_recipe)
    end

    it 'converges succesfully' do
      chef_run
    end

    it 'runs the master recipe' do
      expect(chef_run).to include_recipe('modcloth-solr::master')
    end
  end
end
