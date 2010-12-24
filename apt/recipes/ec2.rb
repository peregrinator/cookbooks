#
# Cookbook Name:: apt
# Recipe:: ec2
#
# Copyright 2010, Bob Burbach
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

# xfs file system tools (for EBS volumes)
package 'xfsprogs' do
  action :install
end