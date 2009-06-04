maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Configures /etc/resolv.conf"
version           "0.7"

attribute "resolver",
  :display_name => "Resolver",
  :description => "Hash of Resolver attributes",
  :type => "hash"

attribute "resolver/search",
  :display_name => "Resolver Search",
  :description => "Default domain to search",
  :default => "domain"

attribute "resolver/nameservers",
  :display_name => "Resolver Nameservers",
  :description => "Default nameservers",
  :type => "array",
  :default => [""]

