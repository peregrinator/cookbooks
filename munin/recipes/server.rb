#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010, Opscode, Inc.
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

#include_recipe "apache2"
#include_recipe "apache2::mod_auth_openid"
#include_recipe "apache2::mod_rewrite"
include_recipe "munin::client"

package "munin"

remote_file "/etc/cron.d/munin" do
  source "munin-cron"
  mode "0644"
  owner "root"
  group "root"
  backup 0
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => node[:munin][:nodes])
end

# our munin conf requires ssl
if @node[:nginx] && @node[:nginx][:ssl_enabled]
  template "#{node[:nginx][:dir]}/sites-enabled/munin" do
    source "munin.nginx.erb"
    mode 0644
  
    if !File.exists?("#{node[:nginx][:dir]}/sites-enabled/munin")
      notifies :reload, resources(:service => "nginx")
    end
  end
end

