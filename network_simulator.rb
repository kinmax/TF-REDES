Dir["./*.rb"].each {|file| require file }
require 'byebug'

if ARGV.length < 4
    puts "[ERROR] Wrong usage.\nCorrect usage: ruby network_simulator.rb <topology_file_path> <node_1> <node_2> <message>"
    exit
end

topology_file_path = ARGV[0]
node1 = ARGV[1]
node2 = ARGV[2]
message = ARGV[3]


begin
    topology_file = File.open(topology_file_path, "r")
    topology = topology_file.read
    topology_file.close
rescue Exception => e
    puts "[ERROR] Error while opening topology file. Check if file path is correct and try again."
    exit
end

begin

    nodes_string = topology.split("#NODE")[1]
    routers_string = topology.split("#ROUTER")[1]
    router_tables_string = topology.split("#ROUTERTABLE")[1]

    nodes = [] 
    nodes_string = nodes_string.split("\n")
    nodes_string.each do |node_string|
        next if node_string.empty?
        break if node_string == "#ROUTER"
        info = node_string.split(",")
        node_name = info[0]
        node_mac = info[1]
        node_ip = info[2]
        node_ip = node_ip.split("/")[0]
        node_cidr = node_ip.split("/")[1].to_i
        node_mtu = info[3].to_i
        node_default_gateway = info[4]
        node = Node.new(node_name, node_mac, node_ip, node_cidr, node_mtu, node_default_gateway)
        nodes << node
    end

    routers = []
    routers_string = routers_string.split("\n")
    routers_string.each do |router_string|
        next if router_string.empty?
        break if router_string == "#ROUTERTABLE"
        info = router_string.split(",")
        router_name = info[0]
        number_of_ports = info[1].to_i
        router_ports_string = info[2..info.length]
        router_ports = []
        router_ports_array = router_ports_string.each_slice(3).to_a
        router_ports_array.each do |router_port_array|
            router_port = RouterPort.new(router_port_array[0],router_port_array[1].split("/")[0], router_port_array[1].split("/")[1].to_i, router_port_array[2].to_i)
            router_ports << router_port
        end
        router = Router.new(router_name, router_ports)
        routers << router
    end

    router_tables_string = router_tables_string.split("\n")
    router_tables_hash = {}
    router_tables_string.each do |router_table_string|
        next if router_table_string.empty?
        router_name = router_table_string.split(",")[0]
        net_dest = router_table_string.split(",")[1].split("/")[0]
        prefix = router_table_string.split(",")[1].split("/")[1].to_i
        next_hop = router_table_string.split(",")[2]
        port = router_table_string.split(",")[3]
        routers.each do |router|
            if router.name == router_name
                router.add_entry_to_router_table(prefix, net_dest, next_hop, port)
                break
            end
        end
    end
rescue Exception
    puts "[ERROR] Incorrect topology file format."
    exit
end

nodes.each do |node|
    node1 = node if node.name == node1
    node2 = node if node.name == node2
end

if node1.class == String
    puts "[ERROR] Source node is not in topology's nodes list"
    exit
end

if node2.class == String
    puts "[ERROR] Destination node is not in topology's nodes list"
    exit
end

if message.empty?
    puts "[ERROR] Message can't be empty."
    exit
end

manager = RequestsManager.new(nodes, routers, node1, node2, message)
