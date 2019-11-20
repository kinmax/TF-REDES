if ARGV.length < 4
    puts "Wrong usage!\nCorrect usage: ruby network_simulator.rb <topology_file_path> <node_1> <node_2> <message_payload>"
    exit
end

topology_file_path = ARGV[0]
node1 = ARGV[1]
node2 = ARGV[2]
payload = ARGV[3]

topology_file = File.open(topology_file_path, "r")
topology = topology_file.read
topology_file.close

nodes_string = topology.split("#NODE")[1]
routers_string = topology.split("#ROUTERS")[1]
router_tables_string = topology.split("#ROUTERTABLE")[1]

nodes_string = nodes_string.split("\n")
nodes_string.each do |node_string|
    info = node_string.split(",")
    node_name = info[0]
    node_mac = info[1]
    node_ip = info[2]
    node_ip = node_ip.split("/")[0]
    node_cidr = node_ip.split("/")[1]
    node_mtu = info[3]
    node_default_gateway = info[4]
end
