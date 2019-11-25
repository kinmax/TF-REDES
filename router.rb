class Router
    attr_reader :name, :router_table, :arp_table, :status, :ports

    VALID_STATUSES = %w(NONE WAITING_ARP_REPLY)

    def initialize(name, ports)
        @name = name
        @router_table = RouterTable.new
        @arp_table = ARPTable.new
        @current_data = ""
        @ports = ports
    end

    def get_router_table_entry(ip)
        router_table.entries.each do |entry|
            if same_network?(ip, entry.ip, entry.cidr)
                return entry
            end
        end
        router_table.entries.each do |entry|
            if entry.ip == "0.0.0.0"
                return entry
            end
        end
        puts "[ERROR] No route found in router #{@name}"
        exit
    end

    def same_network?(ip1, ip2, cidr)
        binary_full_ip = ""
        split_ip = ip1.split(".")
        split_ip.each do |octet|
            binary_full_ip += "%.8b" % octet.to_i
        end
        binary_device_full_ip = ""
        split_ip = ip2.split(".")
        split_ip.each do |octet|
            binary_device_full_ip += "%.8b" % octet.to_i
        end
        if binary_full_ip[0...cidr] == binary_device_full_ip[0...cidr]
            return true
        end
        false
    end

    def add_entry_to_router_table(cidr, dest_ip, next_hop, port)
        @router_table.add_entry(cidr, dest_ip, next_hop, port)
    end

    def add_entry_to_arp_table(ip, mac)
        @arp_table.add_entry(ip, mac)
    end

    def receive_icmp(requests)
        if requests[0].ttl == 1
            send_time_exceeded(requests)
            return nil
        end
        requests.each do |req|
            req.ttl -= 1
        end
        send_icmp(requests)
    end

    def send_icmp(requests)
        dest = requests[0].final_dst
        port = nil
        next_hop = nil
        router_table.entries.each do |entry|
            if same_network?(dest.ip, entry.ip, entry.cidr)
                port = ports[entry.port]
                next_hop = entry.next_hop if entry.next_hop != "0.0.0.0"
                break
            end
        end
        port.send_icmp(requests, next_hop, requests[0].class)
    end

    def send_time_exceeded(requests)
        dest = requests[0].init_src
        port = nil
        next_hop = nil
        router_table.entries.each do |entry|
            if same_network?(dest.ip, entry.ip, entry.cidr)
                port = ports[entry.port]
                next_hop = entry.next_hop if entry.next_hop != "0.0.0.0"
                break
            end
        end
        myreqs = [] 
        requests.each do |req|
            req.final_dst = req.init_src
            req.ttl = 8;
        end
        port.send_icmp(requests, next_hop, ICMPTimeExceeded)
    end

    def receive_arp_request(arp_request)
        @ports.each do |port|
            if port.ip == arp_request.dst_ip
                @arp_table.add_entry(arp_request.src_ip, arp_request.src_mac)
                reply = ARPReply.new(port.mac, arp_request.src_mac, port.ip, arp_request.src_ip)
                return reply
            end
        end
        return nil
    end

    def receive_arp_reply(arp_reply)
        if @status == "WAITING_ARP_REPLY"
            @arp_table.add_entry(arp_reply.src_ip, arp_reply.src_mac)
            @status = "NONE"
            send_packet(@packet_to_send)
        end
    end
end