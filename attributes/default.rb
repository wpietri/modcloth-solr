default.rails_env = 'demo'

default.solr.version = '3.6.0'
default.solr.java_dir = '/usr/java/default'
default.solr.java_options = '-Dsolr.solr.home=/opt/solr/solr $JAVA_OPTIONS'
default.solr.jetty_home = '/opt/solr'
default.solr.jetty_user = 'solr'
default.solr.jetty_log_dir = '/opt/solr/logs'

default.solr.smf_path = '/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin'
default.solr.uses_sunspot = true

default.solr.auto_commit = {
  :max_docs => nil,
  :max_time => nil
}

default.solr.users = []
default.solr.master.hostname = 'localhost'
default.solr.master.port = 9985
default.solr.master.home = '/opt/solr/master'

default.solr.replica.port = 8983
default.solr.replica.home = '/opt/solr/replica'

default.solr.newrelic = {}
default.solr.newrelic.api_key = ''
default.solr.newrelic.apdex_t = '0.02'
default.solr.newrelic.app_name = 'NewRelic application'
default.solr.newrelic.jar = "/opt/solr/newrelic/newrelic.jar"
