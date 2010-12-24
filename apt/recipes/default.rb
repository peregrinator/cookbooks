#
# Cookbook Name:: apt
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


####################################
#
# Add our apt sources
#
####################################

if node[:ec2]
  include_recipe "apt:ec2"
end

# 10-gen source for MongoDB
if node[:mongo]
  template "/etc/apt/sources.list.d/mongo.list" do
    mode 0644
    variables :ubuntu_version => node[:platform_version]
    notifies :run, resources(:execute => "apt-get update"), :immediately
    source "apt/mongo.list.erb"
  end
end


e = execute "apt-get update" do
  action :nothing
end

e.run_action(:run)

%w{/var/cache/local /var/cache/local/preseeding}.each do |dirname|
  directory dirname do
    owner "root"
    group "root"
    mode  0755
    action :create
  end
end
