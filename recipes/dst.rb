include_recipe 'yum-epel'
package %w(ipset nc perf iftop htop)

include_recipe 'mg_perf_iptables::server'

ipt = '/sbin/iptables'
ips = '/usr/sbin/ipset'
execute "#{ipt} --flush"
execute "#{ips} --flush"

main_port = node['http_server_port']
ports = [5050, 5051, 5052, main_port]

num_src = 400
src_ips = []

# get a pool of IPs to play with
num_src.times do |_i|
  third = Random.rand(1..254)
  fourth = Random.rand(1..254)
  ip = "172.29.#{third}.#{fourth}"
  src_ips << ip
end

# allow our test machine's source, see attributes/
src_ips << node['src_ip']

if node['use_simple_iptables']
  ports.each do |port|
    rules = []
    src_ips.each do |ip|
      rule = "#{ipt} -A INPUT -i eth1 -p tcp --dport #{port} --src #{ip} -j ACCEPT"
      rules << rule
    end

    rules << "#{ipt} -A INPUT -i eth1 -p tcp --dport #{port} -j REJECT"

    # applying rules for each port, otherwise argument list too long
    execute 'apply_rules' do
      command rules.join("\n")
      sensitive true # dont want to pollute logs
    end
  end
elsif node['use_ipset']
  # create ipset first
  cmds = ["#{ips} -N org_pool iphash"]

  src_ips.each do |ip|
    cmds << "#{ips} -A org_pool #{ip}"
  end

  execute 'create_ipset' do
    command cmds.join("\n")
    sensitive true
  end

  ports.each do |port|
    rules = []
    rules << "#{ipt} -A INPUT -i eth1 -p tcp --dport #{port} -m set --set org_pool src -j ACCEPT"
    rules << "#{ipt} -A INPUT -i eth1 -p tcp --dport #{port} -j REJECT"

    execute 'apply_rules' do
      command rules.join("\n")
    end
  end
end
