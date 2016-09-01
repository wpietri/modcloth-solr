
solr_mode = node['solr']['mode']


unless solr_mode == 'master' or solr_mode == 'replica'
  raise "must set node['solr'['mode'] to 'master' or 'replica'"
end

include_recipe 'modcloth-java'
include_recipe 'smf'

#
# install solr
#

solr_install_dir = '/opt/solr'
solr_data_dir = '/opt/solr-data'
solr_log_dir = '/var/log/solr'
solr_service = "solr-#{solr_mode}"

user node['solr']['user'] do
  home solr_install_dir
  manage_home false
end

ark 'solr' do
  url "http://tarballs.modcloth.s3.amazonaws.com/apache-solr-#{node['solr']['version']}.tgz"
  version node['solr']['version']
  checksum node['solr']['checksum']
  prefix_root '/opt'
  prefix_home '/opt'
  owner node['solr']['user']
  action :install
end

[solr_install_dir, solr_data_dir, solr_log_dir].each do |dir|
  directory dir do
    owner node['solr']['user']
    mode '0755'
  end
end

template "#{solr_data_dir}/solr.xml" do
  owner node['solr']['user']
  mode '0755'
  notifies :restart, "service[#{solr_service}]"
end

template "#{solr_install_dir}/server/resources/log4j.properties" do
  # owner node['solr']['user']
  mode '0755'
  variables log_dir: solr_log_dir
  notifies :restart, "service[#{solr_service}]"
end


#
# install newrelic
#
install_newrelic = (node['solr']['newrelic']['api_key'] and !node['solr']['newrelic']['api_key'].empty?)

if install_newrelic
  include_recipe 'modcloth-solr::install_newrelic'
end


#
# set up core
#

core_dir = solr_data_dir + "/#{node['solr']['core']}"
conf_dir = core_dir + '/conf'
core_data_dir = core_dir + '/data'

[core_dir, conf_dir, core_data_dir].each do |d|
  directory d do
    owner node['solr']['user']
    mode '0755'
  end
end

file "#{core_dir}/core.properties" do
  content <<-EOF
    name=#{node['solr']['core']}
    config=solrconfig.xml
    schema=schema.xml
    dataDir=data
  EOF
  owner node['solr']['user']
  mode '0755'
end

# TODO: these should have content or be removed
file "#{conf_dir}/stopwords.txt" do
  content ''
  owner node['solr']['user']
  mode '0755'
end

# TODO: these should have content or be removed
file "#{conf_dir}/synonyms.txt" do
  content ''
  owner node['solr']['user']
  mode '0755'
end

template "#{conf_dir}/solrconfig.xml" do
  owner node['solr']['user']
  mode '0755'
  variables(auto_commit: node['solr']['autocommit'])
  notifies :restart, "service[#{solr_service}]"
end


template "#{conf_dir}/schema.xml" do
  owner node['solr']['user']
  mode '0755'
  notifies :restart, "service[#{solr_service}]"
end


#
# set up solr service
#

smf solr_service do
  credentials_user 'solr'
  cmd = []
  cmd << "nohup #{node['modcloth-java']['jdk_base_path']}/#{node['modcloth-java']['jdk_version']}/bin/java"
  cmd << "-Djetty.port=#{node['solr'][solr_mode]['port']}"
  cmd << "-Dsolr.install.dir=#{solr_install_dir}"
  cmd << "-Djetty.home=#{solr_install_dir}/server"
  cmd << "-Dsolr.solr.home=#{solr_data_dir}"
  cmd << "-Denable.#{solr_mode}=true"
  if solr_mode == 'replica'
    cmd << "-Dreplication.url=http://#{node['solr']['master']['hostname']}:#{node['solr']['master']['port']}/solr/#{node['solr']['core']}"
  end
  # JVM incantation from Solr 6.1 startup scripts
  cmd << "-Xmx#{node['solr']['max_memory']}"
  cmd.push(*%w{-Xms512m -XX:NewRatio=3 -XX:SurvivorRatio=4 -XX:TargetSurvivorRatio=90
          -XX:MaxTenuringThreshold=8 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ConcGCThreads=4
          -XX:ParallelGCThreads=4 -XX:+CMSScavengeBeforeRemark -XX:PretenureSizeThreshold=64m
          -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=50
          -XX:CMSMaxAbortablePrecleanTime=6000 -XX:+CMSParallelRemarkEnabled -XX:+ParallelRefProcEnabled
          -verbose:gc -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps
          -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime -Xss256k})
  cmd << "-Xloggc:#{solr_install_dir}/server/logs/solr_gc.log"
  cmd << "-XX:OnOutOfMemoryError=#{solr_install_dir}/bin/oom_solr.sh"


  # # Add NewRelic to start command if an API key is present
  if install_newrelic
    cmd << "-javaagent:#{node.solr.newrelic.jar}"
    cmd << "-Dnewrelic.environment=#{node.application.environment}"
  end

  if node.solr.enable_jmx
    cmd << '-Dcom.sun.management.jmxremote'
  end

  cmd << '-jar start.jar --module=http &'

  start_command cmd.map { |x| x.strip }.join(' ')
  start_timeout 300
  environment 'PATH' => node.solr.smf_path,
              'JAVA_HOME' => "#{node['modcloth-java']['jdk_base_path']}/#{node['modcloth-java']['jdk_version']}"
  working_directory solr_install_dir + '/server'

  notifies :restart, "service[#{solr_service}]"
end

# start solr service
service solr_service do
  action :enable
end
