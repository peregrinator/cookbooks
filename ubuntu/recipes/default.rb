#
# Cookbook Name:: ubuntu
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
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
#

#include_recipe "apt"


### Add our apt sources

template "/etc/apt/sources.list" do
  mode 0644
  variables :code_name => node[:lsb][:codename], :ec2_region => node[:lsb][:ec2_region]
  notifies :run, resources(:execute => "apt-get update"), :immediately
  source "sources.list.erb"
end

### Add libraries we'll need

# nokogiri and calais gems
package "libxml2-dev" do
  action :install
end
package "libxslt1-dev" do
  action :install
end

# patron gem
package "libcurl4-gnutls-dev" do
  action :install
end

# stevedore gem
package "xpdf" do
  action :install
end

####################################
#
# GROUP SETUP
#
###################################

group "mysql" do
  gid 1001
end

group "deploy" do
  gid 1002
end

####################################
#
# USER SETUP
#
###################################

### MYSQL ###

user "mysql" do
  comment "MySQL User"
  uid "1001"
  gid "mysql"
  not_if "cat /etc/password | grep mysql"
end

### DEPLOY ###

user "deploy" do
  comment "Deploy User"
  uid "1002"
  gid "deploy"
  home "/home/deploy"
  shell "/bin/bash"
  #password "$1$JJsvHslV$szsCjVEroftprNn4JHtDi."
  not_if do File.directory?("/home/deploy") end
end

directory "/home/deploy" do
  owner 'deploy'
  group 'deploy'
  mode 0700
  action :create
end

directory "/home/deploy/.ssh" do
  owner 'deploy'
  group 'deploy'
  mode 0700
  recursive true
  action :create
  not_if do File.directory?("/home/deploy/.ssh") end
end

remote_file "/home/deploy/.ssh/authorized_keys" do
  source 'deploy_authorized_keys'
  owner 'deploy'
  group 'deploy'
  mode 0600
  action :create
  not_if do File.exists?("/home/deploy/.ssh/authorized_keys") end
end

remote_file "/home/deploy/.ssh/known_hosts" do
  source 'deploy_known_hosts'
  owner 'deploy'
  group 'deploy'
  mode 0600
  action :create
  not_if do File.exists?("/home/deploy/.ssh/known_hosts") end
end

remote_file "/home/deploy/.ssh/id_rsa" do
  source 'deploy_private_key'
  owner 'deploy'
  group 'deploy'
  mode 0600
  action :create
  not_if do File.exists?("/home/deploy/.ssh/id_rsa") end
end

# add deploy to sudoers without password required
execute "add deploy to sudoers" do
  command "cp /etc/sudoers /etc/sudoers.bak && echo 'deploy  ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers"
  action :nothing
end