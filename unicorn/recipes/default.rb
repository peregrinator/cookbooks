#
# Author:: Adam Jacob <adam@opscode.com>
# Cookbook Name:: unicorn
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

include_recipe "ruby"
include_recipe "rubygems"

gem_package "unicorn"

template "/etc/init/unicorn.conf" do
  source "unicorn.upstart.erb"
end

service "unicorn" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

directory node[:unicorn][:config_dir] do
  recursive true
  action :create
end

template node[:unicorn][:config] do
  source "unicorn.rb.erb"
  cookbook "unicorn"
  mode "0644"
  owner node[:unicorn][:owner]
  group node[:unicorn][:group]
  notifies :restart, resources(:service => "unicorn")
end


