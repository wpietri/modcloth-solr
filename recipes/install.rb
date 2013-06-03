#
# Cookbook Name:: solr
# Recipe:: install
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

include_recipe "java::default"
include_recipe "solr::user"

user = "solr"

package_sha1_checksum = {
  '3.6.0' => '558cdf145ab3bf22fb5d168d3f657df796bda639'
}.fetch(node.solr.version)


remote_file "#{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}.tgz" do
	source "http://tarballs.modcloth.s3.amazonaws.com/apache-solr-#{node.solr.version}.tgz"
	mode "0744"
	# checksum package_sha1_checksum XXX this does not appear to work.  perhaps it's trieuvan.com's fault?
	not_if { File.directory?("#{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}") }
end

execute "checksum solr tar file" do
	command %Q([[ "$(openssl sha1 #{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}.tgz)" =~ "#{package_sha1_checksum}" ]])
	not_if { File.directory?("#{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}") }
end

package_file = "#{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}.tgz"

execute "extract solr tar file into tmp" do
  command "cd #{Chef::Config[:file_cache_path]} && tar -xvf #{package_file}"
  not_if { File.directory?("#{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}") }
end

# install solr
directory "/opt/solr-#{node.solr.version}" do
  owner user
  mode "0755"
  not_if { File.directory?("/opt/solr-#{node.solr.version}") }
end

ruby_block "copy example solr home directory" do
  block do
    ::FileUtils.cp_r "#{Chef::Config[:file_cache_path]}/apache-solr-#{node.solr.version}/example", "/opt/solr-#{node.solr.version}/home_example"
  end
  not_if { File.exists?("/opt/solr-#{node.solr.version}/home_example") }
end

ruby_block "create empty data directory" do
  block do
    ::FileUtils.mkdir_p "/opt/solr-#{node.solr.version}/home_example/solr/data"
  end
  not_if { File.exists?("/opt/solr-#{node.solr.version}/home_example/solr/data") }
end

execute "chown solr directory" do
  command "chown -R #{user} /opt/solr-#{node.solr.version}"
end

link "/opt/solr" do
  owner user
  to "/opt/solr-#{node.solr.version}"
  not_if { File.directory?("/opt/solr") }
end

directory "/var/log/solr" do
  owner user
  mode "0755"
  not_if { File.directory?("/var/log/solr") }
end


