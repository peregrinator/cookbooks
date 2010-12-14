#
# Cookbook Name:: ruby
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

case node[:ruby][:version]
when '1.8'
  package "ruby" do
    action :install
  end

  extra_packages = case node[:platform]
    when "ubuntu","debian"
      %w{
        ruby1.8
        ruby1.8-dev
        rdoc1.8
        ri1.8
        libopenssl-ruby
      }
    when "centos","redhat","fedora"
      %w{
        ruby-libs
        ruby-devel
        ruby-docs
        ruby-ri
        ruby-irb
        ruby-rdoc
        ruby-mode
      }
    end

  extra_packages.each do |pkg|
    package pkg do
      action :install
    end
  end
when '1.9'
  remote_file 'tmp/ruby-1.9.2-p0.tar.gz' do
    source 'ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p0.tar.gz'
    not_if { ::File.exists?("/tmp/ruby-1.9.2-p0.tar.gz") || 
             (::File.exists?("/usr/local/bin/ruby") &&
                system("/usr/local/bin/ruby -v | grep -q '1.9.2p0$'") )
           }
  end
  
  bash "Install Ruby 1.9.2p0 from source" do
    cwd "/tmp"
    code <<-EOH
    tar xvzf ruby-1.9.2-p0.tar.gz
    cd ruby-1.9.2-p0
    ./configure
    make
    make install
    EOH

    not_if do
      ::File.exists?("/usr/local/bin/ruby") &&
      system("/usr/local/bin/ruby -v | grep -q '1.9.2p0$'")
    end
  end
end
