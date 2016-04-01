require 'spec_helper'

describe service('rmiregistry') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/opt/solr-3.6.0') do
  it { should be_directory }
end

describe file('/opt/solr') do
  it { should be_symlink }
  it { should be_linked_to('/opt/solr-3.6.0') }
end

describe user('solr') do
  it { should exist }
end

describe file('/var/log/solr') do
  it { should be_directory }
end

describe file('/opt/solr/home_example/solr/data') do
  it { should be_directory }
end

describe file('/opt/solr/newrelic') do
  it { should be_directory }
end

describe file('/opt/solr/newrelic/newrelic.yml') do
  it { should exist }
  its(:content) { should match /license_key: 'keykeykey'/ }
end

### it seems there should be a better way to test this.
### We need to be able to run this test regardless of whether
### the master or replica recipe is run and it should pass either
### way.   But I don't see an easy way to pass a property to serverspec
### and serverspec has no easy access to the run_list.
if File.exist?('/opt/solr/master')
  solrbase = '/opt/solr/master/'
else
  solrbase = '/opt/solr/replica'
end

describe file("#{solrbase}/solr/conf/solrconfig.xml") do
  it { should exist }
  its(:content) { should match /^\s+<jmx serviceUrl="service:jmx:rmi:\/\/\/jndi\/rmi:\/\/localhost:9999\/solr"\/>/}
end


