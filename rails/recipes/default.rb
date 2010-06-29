#
# Cookbook Name:: rails
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

#include_recipe "ruby"

%w{ rails actionmailer actionpack activerecord activesupport activeresource }.each do |rails_gem|
  gem_package rails_gem do
    if node[:rails][:version]
      version node[:rails][:version]
      action :install
    else
      action :install
    end
  end
end

if node[:chef][:roles].include?('staging')
  template "#{node[:apache][:web_dir]}/apps/#{node[:apache][:name]}/shared/config/database.yml" do
    variables :password => node[:mysql][:server_root_password]
    source "staging.database.yml.erb"
    mode 0644
  end
elsif node[:chef][:roles].include?('app') || node[:chef][:roles].include?('worker')
  template "#{node[:apache][:web_dir]}/apps/#{node[:apache][:name]}/shared/config/database.yml" do
    variables :host => node[:mysql][:server_address], 
              :port => node[:mysql][:server_port],
              :password => node[:mysql][:server_root_password]
    source "app_server.database.yml.erb"
    mode 0644
  end
end

gem_package "bundler" do
  version "0.9.26"
end

link "/usr/bin/bundle" do
  to "#{node[:ruby_enterprise][:install_path]}/bin/bundle"
end

execute "bundle install" do
  command "bundle install /home/deploy/.bundle --gemfile #{node[:apache][:web_dir]}/apps/#{node[:apache][:name]}/shared/tmp/Gemfile --without development test"
  user "#{node[:capistrano][:deploy_user]}"
  group "#{node[:capistrano][:deploy_user]}"
  action :nothing
end
 
%w(Gemfile Gemfile.lock).each do |f|
  template "#{node[:apache][:web_dir]}/apps/#{node[:apache][:name]}/shared/tmp/#{f}" do
    source "#{f}"
    notifies :run, resources(:execute => "bundle install")
  end
  
  file "#{node[:apache][:web_dir]}/apps/#{node[:apache][:name]}/shared/tmp/#{f}" do
    owner "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
  end
end