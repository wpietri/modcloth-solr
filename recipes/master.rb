#
# Cookbook Name:: solr
# Recipe:: master
#
# Copyright 2010, ModCloth, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "solr::user"
include_recipe "solr::install"
include_recipe "solr::install_newrelic"
include_recipe "smf::default"

auto_commit_enabled = node.solr.auto_commit.max_docs && node.solr.auto_commit.max_time

# configure solr
ruby_block "copy example solr home into master" do
  block do
    ::FileUtils.cp_r "/opt/solr/home_example", node.solr.master.home
    ::FileUtils.chown_R "solr", "root", node.solr.master.home
  end
  not_if { File.directory?(node.solr.master.home) }
end

log_configuration = "#{node.solr.master.home}/log.conf"
template log_configuration do
  source "solr-master-log.conf.erb"
  owner "solr"
  mode "0700"
  not_if { File.exists?("#{node.solr.master.home}/log.conf") }
end

template "#{node.solr.master.home}/solr/conf/solrconfig.xml" do
  owner "solr"
  mode "0600"
  variables({
    :role => "master",
    :config => node.solr,
    :auto_commit => auto_commit_enabled
  })
end

if node.solr.uses_sunspot
  template "#{node.solr.master.home}/solr/conf/schema.xml" do
    owner "solr"
    mode "0600"
  end
end

# create/import smf manifest
smf "solr-master" do
  credentials_user "solr"
  cmd = []
  cmd << "nohup java -Djetty.port=#{node.solr.master.port}"
  cmd << "-Djava.util.logging.config.file=#{log_configuration}"
  cmd << "-Dsolr.data.dir=#{node.solr.master.home}/solr/data"

  # Add NewRelic to start command if an API key is present
  cmd << "-javaagent:#{node.solr.newrelic.jar}" unless node.solr.newrelic.api_key.to_s.empty?
  cmd << "-Dnewrelic.environment=#{node.application.environment}" unless node.solr.newrelic.api_key.to_s.empty?

  cmd << "-jar start.jar &"
  start_command cmd.join(' ')
  start_timeout 300
  environment "PATH" => node.solr.smf_path
  working_directory node.solr.master.home
end

solr_master = rbac "solr-master"
node.solr.users.each do |user|
  if user != "solr" && user != "root"
    ruby_block "Allow user #{user} to manage solr master" do
      block do
        Chef::Resource::Rbac.permissions[user] ||= []
        Chef::Resource::Rbac.permissions[user] << "solr-master"
        notifies :apply, solr_master
      end
      only_if "id -u #{user}"
    end
  end
end

# start solr service
service "solr-master" do
  action :enable
end
