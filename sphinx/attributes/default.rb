default[:sphinx][:version]="sphinx-0.9.9"
default[:sphinx][:url]="http://www.sphinxsearch.com/downloads/#{sphinx[:version]}.tar.gz"
default[:sphinx][:path]="/opt/#{sphinx[:version]}"
default[:sphinx][:src_path]="/opt/src"
default[:sphinx][:tar_file]="#{sphinx[:src_path]}/#{sphinx[:version]}.tar.gz"
default[:sphinx][:libstemmer]=false
default[:sphinx][:configure_options]="" #"--with-libstemmer"
default[:sphinx][:tar_file_checksum]=""
