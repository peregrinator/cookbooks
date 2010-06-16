#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: apparmor
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

case node[:platform]
when "ubuntu"
  service "apparmor" do
    enabled true
    running true
    supports :start => true, :stop => true, :restart => true, :reload => true, :status => true
    action [:reload, :restart]
  end
end

directory "/etc/apparmor.d" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if "test -d /etc/apparmor.d"
end


%w(usr.sbin.mysqld).each do |file|
  template "/etc/apparmor.d/#{file}" do
    source "#{file}.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "apparmor")
  end
end
