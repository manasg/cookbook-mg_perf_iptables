include_recipe 'mg_golang'

http_server_src_d = "#{node['golang']['ws_d']}/src/http_server"

directory http_server_src_d do
  recursive true
end

cookbook_file "#{http_server_src_d}/http_server.go" do
  source 'http_server.go'
  notifies :run, 'execute[compile]'
end

execute 'compile' do
  command "source #{node['golang']['var_sh']} && \
    cd #{http_server_src_d} && \
    go get github.com/gorilla/handlers && \
    go build http_server.go"
  action :nothing
  notifies :restart, 'runit_service[http_server]'
end

node.default['http_server_bin'] = "#{http_server_src_d}/http_server"

include_recipe 'runit'

runit_service 'http_server' do
  default_logger true
end
