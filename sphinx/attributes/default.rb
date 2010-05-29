set_unless[:sphinx][:version]="sphinx-0.9.9"
set_unless[:sphinx][:url]="http://www.sphinxsearch.com/downloads/#{sphinx[:version]}.tar.gz"
set_unless[:sphinx][:path]="/opt/#{sphinx[:version]}"
set_unless[:sphinx][:src_path]="/opt/src"
set_unless[:sphinx][:tar_file]="#{sphinx[:src_path]}/#{sphinx[:version]}.tar.gz"
set_unless[:sphinx][:libstemmer]=false
set_unless[:sphinx][:configure_options]="" #"--with-libstemmer"
set_unless[:sphinx][:tar_file_checksum]=""
