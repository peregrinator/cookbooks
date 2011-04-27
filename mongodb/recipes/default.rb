#
# Cookbook Name:: mongodb
# Recipe:: default

group node[:mongodb][:group] do
  action [ :create, :manage ]
end

user node[:mongodb][:user] do
  comment "MongoDB Server"
  gid node[:mongodb][:group]
  home node[:mongodb][:root]
  action [ :create, :manage ]
end

[node[:mongodb][:log_dir], node[:mongodb][:data_dir], node[:mongodb][:pid_dir]].each do |dir|
  directory dir do
    owner node[:mongodb][:user]
    group node[:mongodb][:group]
    mode 0755
    recursive true
    action :create
    not_if { File.directory?(dir) }
  end
end

remote_file "/tmp/#{node[:mongodb][:file_name]}.tgz" do
  source node[:mongodb][:url]
  not_if do
    ::File.exists?("/tmp/#{node[:mongodb][:file_name]}.tgz") || 
    ( ::File.exists?('/usr/local/bin/mongod') &&
      system("/usr/local/bin/mongod -v | grep -q '#{node[:mongodb][:version]}'")
    )
  end
end

bash "install-mongodb" do
  cwd "/tmp"
  code <<-EOH
    tar zxvf #{node[:mongodb][:file_name]}.tgz
    mv -f #{node[:mongodb][:file_name]}/ #{node[:mongodb][:root]}
  EOH
  not_if { ::File.exists?('/usr/local/bin/mongod') &&
           system("/usr/local/bin/mongod -v | grep -q '#{node[:mongodb][:version]}'") 
         }
end


%w(bsondump mongod mongoexport mongoimport mongos mongostat mongo mongodump mongofiles mongorestore mongosniff).each do |binary|
  link "/usr/local/bin/#{binary}" do
    to "/usr/local/mongodb/bin/#{binary}"
  end
end

# create config directory and file
directory "/etc/mongodb" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

template "/etc/mongodb/mongodb.conf" do
  source "mongodb.conf.erb"
  owner "root"
  group "root"
  mode 0744
  #notifies :restart, resources(:service => "mongodb")
end