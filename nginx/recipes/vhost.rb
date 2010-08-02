#
# Cookbook Name:: nginx
# Recipe:: vhost
# Author:: Bob Burbach, Github: Peregrinator
#
# Copyright 2010, Critical Juncture, LLC.
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
# This recipe sets up the directories for the logs of our vhost
# as well as rotation of those logs via logrotate


# set up log directory for the vhost
directory "#{node[:nginx][:log_dir]}/#{node[:nginx][:host_name]}" do
  action :create
  recursive true
end

# create a logrotate conf file for the vhost
template "/etc/logrotate.d/nginx-#{node[:nginx][:host_name]}" do
  source "logrotate.erb"
  variables :log_path  => "#{node[:nginx][:log_dir]}/#{node[:nginx][:host_name]}",
            :interval  => node[:nginx][:logrotate][:vhost][:interval],
            :keep_for  => node[:nginx][:logrotate][:vhost][:keep_for]
  mode 0644
  owner "root"
  group "root"
end