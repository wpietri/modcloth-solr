default.application.environment = 'demo'

default['solr']['user'] = 'solr'
default['solr']['version'] = '6.1.0'
default['solr']['checksum'] = '74630a06d45eb44c0afe2bfb6e2cd80c9d8d92aa0c48a563e39c32996a76c8b0'

default['solr']['java_dir'] = '/usr/java/default'
default['solr']['max_memory'] = '6144m'
default['solr']['java_options'] = nil

default['solr']['smf_path'] = '/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin'
default['solr']['uses_sunspot'] = true

default['solr']['auto_commit'] = {
  max_docs: nil,
  max_time: nil
}
default['solr']['core'] = 'ecomm'

default['solr']['users'] = ['ecomm']
default['solr']['master']['hostname'] = 'localhost'
default['solr']['master']['port'] = 9985
default['solr']['master']['home'] = '/opt/solr/master'

default['solr']['replica']['port'] = 8983
default['solr']['replica']['home'] = '/opt/solr/replica'

default['solr']['newrelic']['api_key'] = ''
default['solr']['newrelic']['apdex_t'] = '0.02'
default['solr']['newrelic']['app_name'] = 'NewRelic application'
default['solr']['newrelic']['jar'] = '/opt/solr/newrelic/newrelic.jar'

default.solr.enable_jmx = true
