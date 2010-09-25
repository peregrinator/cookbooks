#
# Author:: Bob Burbach (<info@criticaljuncture.org>)
# Cookbook Name:: nodejs
# Recipe:: default
# Description:: "Installs and configures Node.js"
# Version:: "0.1"
# Copyright 2010, Critical Juncture
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

directory node[:nodejs][:source_path] do
  mode 0755
  action :create
  recursuve true
end

git node[:nodejs][:source_path] do
  repository node[:nodejs][:source_url]
  reference "v#{node[:nodejs][:version]}"
  action :sync
end

bash "Install NodeJS #{node[:redis][:version]} from git source" do
  cwd "#{node[:nodejs][:source_path]}/node"
  code <<-EOH
  ./configure
  make
  make install
  EOH

  not_if do
    ::File.exists?("/usr/local/bin/node") &&
    system("/usr/local/bin/node -v | grep -q '#{node[:nodejs][:version]}'")
  end
end

if node[:nodejs][:install_npm] == "yes"
  bash "Install Node Package Manager" do
  cwd node[:nodejs][:source_path]
  code <<-EOH
  curl http://npmjs.org/install.sh | sh
  EOH
  end
  
  not_if do
    ::File.exists?("/usr/local/bin/npm") &&
    system("/usr/local/bin/npm -v | grep -q '#{node[:nodejs][:version]}'")
  end
end
