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

include_recipe "apt"
include_recipe "ssh"

####################################
#
# Add libraries we'll need
#
####################################

# varnish
# package "libpcre3-dev" do
#   action :install
# end

# used by apache and ngix for creating passwords for basic auth
package "apache2-utils" do
  action :install
end

if node[:ec2]
  # used for backups on ec2
  package "ec2-consistent-snapshot" do
    action :install
  end
  
  # used for getting newly spun up servers up to date
  # ie pull from git, set proper backup cron jobs, etc.
  package "runurl" do
    action :install
  end
end

####################################
#
# USER/GROUP SETUP
#
####################################

### MYSQL ###
if node[:ubuntu] && node[:ubuntu][:users] && node[:ubuntu][:users][:mysql]
  group "mysql" do
    gid 1100
    not_if "cat /etc/group | grep deploy"
  end
  
  user "mysql" do
    comment "MySQL User"
    uid "3000"
    gid "mysql"
    not_if "cat /etc/password | grep mysql"
  end
end

### DEPLOY ###
if node[:ubuntu] && node[:ubuntu][:users] && node[:ubuntu][:users][:deploy]
  group "deploy" do
    gid 1002
    not_if "cat /etc/group | grep deploy"
  end
  
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

  %w(known_hosts).each do |file|
    remote_file "/home/deploy/.ssh/#{file}" do
      source "users/deploy/#{file}"
      owner 'deploy'
      group 'deploy'
      mode 0600
      action :create
      not_if do File.exists?("/home/deploy/.ssh/#{file}") end
    end
  end

  template "/home/deploy/.ssh/authorized_keys" do
    source "users/authorized_keys.erb"
    owner 'deploy'
    group 'deploy'
    variables :private_key => node[:ubuntu][:users][:deploy][:authorized_keys]
    mode 0600
    action :create
    not_if do File.exists?("/home/deploy/.ssh/authorized_keys") end
  end

  template "/home/deploy/.ssh/id_rsa" do
    source "users/id_rsa.erb"
    owner 'deploy'
    group 'deploy'
    variables :private_key => node[:ubuntu][:users][:deploy][:private_key]
    mode 0600
    action :create
    not_if do File.exists?("/home/deploy/.ssh/id_rsa") end
  end

  # add deploy to sudoers without password required
  execute "add deploy to sudoers" do
    command "cp /etc/sudoers /etc/sudoers.bak && echo 'deploy  ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers"
    not_if "cat /etc/sudoers | grep \"deploy  ALL=(ALL) NOPASSWD:ALL\""
  end

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

  if node[:aws][:ebs][:backup]
    if node[:mysql]
      template "/etc/cron.d/ebs_backup" do
        variables :ebs_volume_id   => node[:aws][:ebs][:database][:volume_id],
                  :mysql_user      => 'root', 
                  :mysql_passwd    => node[:mysql][:server_root_password],
                  :xfs_mount_point => node[:aws][:ebs][:database][:mount_point],
                  :description     => "ebs-backup-mysql-#{node[:apache][:name]}",
                  :log             => node[:ubuntu][:backup_log_dir]
        source "cron/roles/mysql/ebs_backup.erb"
        mode 0644
      end
    else
      template "/etc/cron.d/ebs_backup" do
        variables :ebs_volume_id   => node[:aws][:ebs][:worker][:volume_id],
                  :xfs_mount_point => node[:aws][:ebs][:worker][:mount_point],
                  :description     => "ebs-backup-#{node[:apache][:name]}",
                  :log             => node[:ubuntu][:backup_log_dir]
        source "cron/roles/standard/ebs_backup.erb"
        mode 0644
      end
    end
  end
  
  execute "Get Amazon private key" do
    cwd "/mnt"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get config.internal.federalregister.gov:private_key.pem private_key.pem"
  end
  
  execute "Get Amazon x509 cert" do
    cwd "/mnt"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get config.internal.federalregister.gov:cert.pem cert.pem"
  end

  execute "add private key environment variable" do
    command "echo export EC2_PRIVATE_KEY='/mnt/private_key.pem' | tee -a /etc/profile"
    not_if do
      system("cat /etc/profile | grep -q 'export EC2_PRIVATE_KEY'")
    end
  end
  
  execute "add cert to environment variable" do
    command "echo export EC2_CERT='/mnt/cert.pem' | tee -a /etc/profile"
    not_if do
      system("cat /etc/profile | grep -q 'export EC2_CERT'")
    end
  end
end


# customize syslog rotation (based on 9.10 rsyslog defaults)
template "/etc/logrotate.d/rsyslog" do
  source "syslog_logrotate.erb"
  variables :log_path  => "/var/log/syslog",
            :interval  => node[:ubuntu][:logrotate][:syslog][:interval],
            :keep_for  => node[:ubuntu][:logrotate][:syslog][:keep_for]
  mode 0644
  owner "root"
  group "root"
end

# create log for backups this allows us to troubleshoot log backups
directory "/var/log/cron" do
  owner 'root'
  group 'root'
  mode 0744
  recursive true
  action :create
  not_if do File.directory?("/var/log/cron") end
end

file "/var/log/cron/backup.log" do
  action :create
  only_if do ! File.exists?("/var/log/cron/backup.log") end
end


####################################
#
# ETC HOSTS SETUP
#
####################################

template "/etc/hosts" do
  variables :proxy_server_ip     => node[:ubuntu][:proxy_server][:ip],
            :proxy_server_fqdn   => node[:ubuntu][:proxy_server][:fqdn],
            :proxy_server_alias  => node[:ubuntu][:proxy_server][:alias],
            :static_server_ip    => node[:ubuntu][:static_server][:ip],
            :static_server_fqdn  => node[:ubuntu][:static_server][:fqdn],
            :static_server_alias => node[:ubuntu][:static_server][:alias],
            :worker_server_ip    => node[:ubuntu][:worker_server][:ip],
            :worker_server_fqdn  => node[:ubuntu][:worker_server][:fqdn],
            :worker_server_alias => node[:ubuntu][:worker_server][:alias],
            :database_ip         => node[:ubuntu][:database][:ip],
            :database_fqdn       => node[:ubuntu][:database][:fqdn],
            :database_alias      => node[:ubuntu][:database][:alias],
            :sphinx_ip           => node[:ubuntu][:sphinx][:ip],
            :sphinx_fqdn         => node[:ubuntu][:sphinx][:fqdn],
            :sphinx_alias        => node[:ubuntu][:sphinx][:alias]
  source "etc_hosts.erb"
  mode 0644
end

####################################
#
# SSH SETUP
#
####################################

service "ssh" do
  case node[:platform]
  when "centos","redhat","fedora"
    service_name "sshd"
  else
    service_name "ssh"
  end
  supports :restart => true
  action [ :enable, :start ]
end

remote_file "/etc/ssh/ssh_config" do
  source "ssh/ssh_config"
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :restart, resources(:service => "ssh")
end