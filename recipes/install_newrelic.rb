if node['solr']['newrelic']['api_key'].to_s.empty?
  log('no solr api_key set, skipping installation of newrelic.jar') { level :info }
else
  log('solr api_key set, installation of newrelic.jar') { level :info }

  jar = node['solr']['newrelic']['jar']

  directory File.dirname(jar) do
    owner user
    mode 0755
  end

  remote_file jar do
    source 'http://download.newrelic.com/newrelic/java-agent/newrelic-agent/3.28.0/newrelic-agent-3.28.0.jar'
    mode '0744'
    not_if { File.file?(jar) }
  end

  log("node.solr.newrelic -> #{node['solr']['newrelic'].inspect}") { level :info }

  template ::File.join(::File.dirname(jar), 'newrelic.yml') do
    source 'newrelic.yml.erb'
    owner node.solr.jetty_user
    mode 0644
    variables(newrelic: node['solr']['newrelic'])
  end
end
