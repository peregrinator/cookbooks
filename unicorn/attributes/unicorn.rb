default_unless[:unicorn][:config_dir] = "#{node[:app][:root_dir]}/config"
default_unless[:unicorn][:config]     = "#{node[:unicorn][:config_dir]}/unicorn.rb"
default_unless[:unicorn][:listen]     = 'tcp'

if node[:unicorn][:listen][:type] == 'tcp'
  default_unless[:unicorn][:listen][:address]    = 8080
  default_unless[:unicorn][:listen][:tcp_nopush] = true
elsif node[:unicorn][:listen][:type] == 'socket'
  default_unless[:unicorn][:listen][:address] = "#{node[:app][:root_dir]}/tmp/sockets/unicorn.sock"
  default_unless[:unicorn][:listen][:backlog] = 1024
end

default_unless[:unicorn][:pid_dir] = "#{node[:app][:root_dir]}/tmp/pids"
default_unless[:unicorn][:pid]     = "#{node[:unicorn][:pid_dir]}/unicorn.pid"

default_unless[:unicorn][:worker_processes]  = cpu[:total]
default_unless[:unicorn][:working_directory] = node[:app][:root_dir]
default_unless[:unicorn][:worker_timeout]    = 30

default_unless[:unicorn][:stderr_log] = "#{node[:app][:root_dir]}/log/unicorn.stderr.log"
default_unless[:unicorn][:stdout_log] = "#{node[:app][:root_dir]}/log/unicorn.stdout.log"

default_unless[:unicorn][:preload_app]
default_unless[:unicorn][:before_fork]
default_unless[:unicorn][:after_fork]


# only created in config file if the ruby version supports
# copy on write (ie REE)
default_unless[:unicorn][:copy_on_write_friendly] = true

default_unless[:unicorn]
default_unless[:unicorn]