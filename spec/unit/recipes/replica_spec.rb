require 'spec_helper.rb'
describe 'modcloth-solr::replica' do
  before do
    stub_command('id -u ecomm').and_return('111')
  end

  context 'When all attributes are default on unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
      end.converge(described_recipe)
    end

    it 'Executes a ruby block to copy the solr home' do
      expect(chef_run).to run_ruby_block('copy example solr home into replica')
    end

    ### This resource is not idempotent.
    it 'Executes a command to recursively chown the solr home directory' do
      expect(chef_run).to run_execute('chown solr replica directory')
    end

    it 'Renders template solr-replica-log.conf' do
      expect(chef_run).to render_file('/opt/solr/replica/log.conf')
    end

    it 'Renders template solrconfig.xml' do
      expect(chef_run).to render_file('/opt/solr/replica/solr/conf/solrconfig.xml')
    end

    it 'Renders template schema.xml' do
      expect(chef_run).to render_file('/opt/solr/replica/solr/conf/schema.xml')
      expect(chef_run).to_not render_file('/opt/solr/master/solr/conf/schema.xml')
    end

    ### SMF and RBAC tests here?

    it 'Renders template jetty.xml' do
      expect(chef_run).to render_file('/opt/solr-3.6.0/replica/etc/jetty.xml')
    end
  end
end
