maintainer        "Bob Burbach"
maintainer_email  "info@criticaljuncture.org"
license           "Apache 2.0"
description       "Installs and configures Node.js"
version           "0.1"

%w{ubuntu debian}.each do |os|
  supports os
end

attribute "nodejs",
  :display_name => "Node.JS",
  :description => "Hash of Node.JS attributes",
  :type => "hash"
attribute "nodejs/address",
  :display_name => "Redis server IP address",
  :description => "IP address to bind.  The default is any.",
  :default => "0.0.0.0"