include_recipe 'yum-epel'
package ['httpd-tools', 'telnet', 'iftop', 'htop']

# load test gen
# could get pre-compiled binary, then don't need go installed
include_recipe 'mg_golang'

vegeta_bin = "#{node['golang']['ws_d']}/bin/vegeta"

execute 'get_vegeta' do
  command "source #{node['golang']['var_sh']} && \
    go get -u github.com/tsenart/vegeta"
  creates vegeta_bin
end

num_bytes = 1024 * 500
data_f = '/tmp/data.txt'

file data_f do
  content 'z' * num_bytes
end

# vegeta cmds
dst_ip = node['dst_ip']
port = node['http_server_port']

cmds = [
  "POST http://#{dst_ip}:#{port}/hello?sleep_ms=1000",
  "@#{data_f}",
]

test_suite = '/tmp/vegeta_test.txt'

file test_suite do
  content cmds.join("\n")
end

# req/sec
rps = 750
duration = '60s'
run_cmd = "ulimit -n 500000 && cat #{test_suite} | \
  #{vegeta_bin}  attack  -rate #{rps} -duration #{duration} | \
  #{vegeta_bin} report"

# should be run by root
file '/tmp/run' do
  content run_cmd
  mode '744'
end
