# create a logrotate conf file for the app
template "/etc/logrotate.d/rails" do
  source "logrotate.erb"
  variables :log_path  => "#{node[:apache][:web_dir]}/apps/#{node[:apache][:name]}/current/log",
            :internval => node[:rails][:logrotate][:interval],
            :keep_for  => node[:rails][:logrotate][:keep_for]
  mode 0644
  owner "root"
  group "root"
end