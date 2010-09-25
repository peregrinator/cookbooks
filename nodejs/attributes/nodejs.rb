set_unless[:nodejs][:source_url] = "git://github.com/ry/node.git"
set_unless[:nodejs][:source_path] = "/usr/local/src"
set_unless[:nodejs][:version] = "0.2.2"

# node package manager
set_unless[:nodejs][:install_npm] = "yes"

if nodejs[:install_npm] == "yes"
  set_unless[:nodejs][:npm_packages] = ["htmlparser", "jsdom"]
end