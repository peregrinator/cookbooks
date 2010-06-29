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

####################################
#
# Add our apt sources
#
####################################

if node[:ec2]
  template "/etc/apt/sources.list" do
    mode 0644
    variables :code_name => node[:lsb][:codename], :ec2_region => node[:lsb][:ec2_region]
    notifies :run, resources(:execute => "apt-get update"), :immediately
    source "apt/sources.list.erb"
  end

  # ec2-consistent-snapshot lives here...
  template "/etc/apt/sources.list.d/alestic-ppa.list" do
    mode 0644
    variables :code_name => node[:lsb][:codename]
    notifies :run, resources(:execute => "apt-get update"), :immediately
    source "apt/alestic-ppa.list.erb"
  end
  execute "add apt signature keys for alestic ppa" do
    command "apt-key adv --keyserver keys.gnupg.net --recv-keys BE09C571"
    user 'root'
  end
end

# 10-gen source for MongoDB
template "/etc/apt/sources.list.d/mongo.list" do
  mode 0644
  variables :ubuntu_version => node[:platform_version]
  notifies :run, resources(:execute => "apt-get update"), :immediately
  source "apt/mongo.list.erb"
end

####################################
#
# Add libraries we'll need
#
####################################

# varnish
package "libpcre3-dev" do
  action :install
end
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
####################################

group "mysql" do
  gid 1100
  not_if "cat /etc/group | grep deploy"
end

group "deploy" do
  gid 1002
  not_if "cat /etc/group | grep deploy"
end

####################################
#
# USER SETUP
#
####################################

### MYSQL ###

user "mysql" do
  comment "MySQL User"
  uid "3000"
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

%w(authorized_keys known_hosts id_rsa).each do |file|
  remote_file "/home/deploy/.ssh/#{file}" do
    source "users/deploy/#{file}"
    owner 'deploy'
    group 'deploy'
    mode 0600
    action :create
    not_if do File.exists?("/home/deploy/.ssh/#{file}") end
  end
end

# add deploy to sudoers without password required
execute "add deploy to sudoers" do
  command "cp /etc/sudoers /etc/sudoers.bak && echo 'deploy  ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers"
  not_if "cat /etc/sudoers | grep \"deploy  ALL=(ALL) NOPASSWD:ALL\""
end


####################################
#
# CRON SETUP
#
####################################

# our ubuntu image from EC2 has this by default for some reason...
file "/etc/cron.d/php5" do
  action :delete
  only_if do File.exists?("/etc/cron.d/php5") end
end

if node[:ec2]
  # Needed to remove old snapshots from amazon
  # Relies on .awssecret being present in /mnt and 
  # symlinked to /root/.awssecret
  template "/mnt/.awssecret" do
    variables :accesskey => node[:aws][:accesskey], :secretkey => node[:aws][:secretkey]
    source "awssecret.erb"
    mode 0644
  end

  link "/root/.awssecret" do
    to "/mnt/.awssecret"
  end

  template "/etc/cron.d/ebs_backup" do
    variables :ebs_volume_id => node[:aws][:ebs][:volume_id],
              :mysql_user    => 'root', 
              :mysql_passwd  => node[:mysql][:server_root_password],
              :description   => node[:apache][:name],
              :log           => "/mnt/backup.log"
    source "cron/ebs_backup.erb"
    mode 0644
  end
end

template "/etc/cron.d/fr2_data" do
  variables :apache_web_dir => node[:apache][:web_dir], 
            :app_name       => node[:apache][:name], 
            :rails_env      => node[:rails][:environment],
            :run_user       => node[:capistrano][:deploy_user]
  source "cron/fr2_data.erb"
  mode 0644
end
