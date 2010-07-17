default[:nginx][:version]      = "0.7.62"
default[:nginx][:install_path] = "/opt/nginx-#{nginx[:version]}"
default[:nginx][:src_binary]   = "#{nginx[:install_path]}/sbin/nginx"

case platform
when "debian","ubuntu"
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
else
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
end

default[:nginx][:configure_flags] = [
  "--prefix=#{nginx[:install_path]}",
  "--conf-path=#{nginx[:dir]}/nginx.conf",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module"
]

default[:nginx][:client_max_body_size] = '5M'

default[:nginx][:listen_host] = '127.0.0.1'
default[:nginx][:listen_port] = '80'

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_http_version] = "1.0"
default[:nginx][:gzip_comp_level] = "2"
default[:nginx][:gzip_proxied] = "any"
default[:nginx][:gzip_buffers] = '16 8k'
default[:nginx][:gzip_min_length] = 0
default[:nginx][:gzip_types] = [
  "text/plain",
  "text/html",
  "text/css",
  "application/x-javascript",
  "application/javascript",
  "text/javascript",
  "text/xml",
  "application/xml",
  "application/xml+rss"
]

default[:nginx][:keepalive]          = "on"
default[:nginx][:keepalive_timeout]  = 65
default[:nginx][:worker_processes]   = cpu[:total]
default[:nginx][:worker_connections] = 2048
default[:nginx][:server_names_hash_bucket_size] = 64

default[:nginx][:logrotate][:vhost][:interval] = 'daily'
default[:nginx][:logrotate][:vhost][:keep_for] = '365'

# default acts funny with false defaults (it overwrites true and is thus always false!)
#default[:nginx][:varnish_proxy] = false
default[:nginx][:varnish_proxy_host] = '127.0.0.1'
default[:nginx][:varnish_weight] = 10
default[:nginx][:varnish_max_fails] = 3
default[:nginx][:varnish_fail_timeout] = '15s'
