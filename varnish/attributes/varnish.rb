case platform
when "debian","ubuntu"
  set_unless[:varnish][:dir]     = "/etc/varnish"
  set_unless[:varnish][:default] = "/etc/default/varnish"
end

set_unless[:varnish][:version] = '2.1.2'
set_unless[:varnish][:url]     = "http://sourceforge.net/projects/varnish/files/varnish/#{node[:varnish][:version]}/varnish-#{node[:varnish][:version]}.tar.gz/download"


# default options
set_unless[:varnish][:vcl_conf]       = '/etc/varnish/default.vcl'
# Binding to 0.0.0.0 typically indicates that the process is listening 
# on all configured IPv4 addresses on all interfaces
# On ec2 the machine is connected via an elastic_ip and doesn't know it's ipaddress
set_unless[:varnish][:listen_address] = '0.0.0.0'
set_unless[:varnish][:listen_port]    = '6081'

# admin options
set_unless[:varnish][:admin_listen_address] = '0.0.0.0'
set_unless[:varnish][:admin_listen_port]    = '6082'

# where to proxy requests to
set_unless[:varnish][:proxy_host] = '127.0.0.1',
set_unless[:varnish][:proxy_port] = '8080'

# THREAD SETTINGS
#bottom limit for the number of threads to maintain, per pool, regardless of traffic
set_unless[:varnish][:min_threads]           = 800 
#the maximum, collectively for all pools
set_unless[:varnish][:max_threads]           = 4000 
#probably want one pool per core
set_unless[:varnish][:thread_pools]          = 1
#delay between the launching of each thread
set_unless[:varnish][:thread_pool_add_delay] = 1
set_unless[:varnish][:thread_timeout]        = 120

# if setting malloc you will only need to set the storage size - storage file is not used with malloc
set_unless[:varnish][:storage_type] = 'malloc'
set_unless[:varnish][:storage_file] = '/tmp'
set_unless[:varnish][:storage_size] = '1G'
set_unless[:varnish][:varnish_ttl]  = 120

# Maximum number of open files (for ulimit -n)
set_unless[:varnish][:nfiles] = 131072


# **** THIS PARAM BORKS OUR VARNISH IF WE SET IT ****
# To avoid locking, Varnish allocates a chump of memory to each thread, session and object. 
# While keeping the object workspace small is a good thing to reduce the memory footprint 
# sometimes the session workspace is a bit too small, specially when ESI is in use. 
# The default sess_workspace is 16kB
#set_unless[:varnish][:session_workspace_size] = 64*1024 #64k 