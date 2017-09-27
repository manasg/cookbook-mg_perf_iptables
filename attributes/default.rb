default['http_server_port'] = 45000
default['http_server_listen'] = "0.0.0.0:#{node['http_server_port']}"

# see .kitchen.yml
# could have specified these in .kitchen.yml, but would have to do for both servers
# alternatively have some data in test/integration/nodes
default['dst_ip'] = '172.28.3.10'
default['src_ip'] = '172.28.3.11'

# cannot have true on both, only one is applied
# both false = no IP filtering
default['use_simple_iptables'] = false
default['use_ipset'] = true
