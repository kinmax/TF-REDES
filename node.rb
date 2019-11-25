class Node
    attr_reader :name, :mac, :ip, :cidr, :mtu, :default_gateway, :arp_table, :status

    VALID_STATUSES = %w(NONE WAITING_ARP_REPLY WAITING_ECHO_REPLY)

    def initialize(name, mac, ip, cidr, mtu, default_gateway)
        @name = name
        @mac = mac
        @ip = ip
        @cidr = cidr
        @mtu = mtu
        @default_gateway = default_gateway
        @arp_table = ARPTable.new
        @current_data = ""
        @status = "NONE"
        @destination = nil
        @reply = false
    end

    def add_nodes(nodes)
        @nodes = nodes
    end

    def add_routers(routers)
        @routers = routers
    end

    def same_network?(device)
        binary_full_ip = ""
        split_ip = @ip.split(".")
        split_ip.each do |octet|
            binary_full_ip += "%.8b" % octet.to_i
        end
        binary_device_full_ip = ""
        split_ip = device.ip.split(".")
        split_ip.each do |octet|
            binary_device_full_ip += "%.8b" % octet.to_i
        end
        if binary_full_ip[0...@cidr] == binary_device_full_ip[0...@cidr]
            return true
        end
        false
    end

    def devices_on_same_net
        devices = []
        @nodes.each do |node|
            devices << node if same_network?(node) && node.ip != @ip
        end
        @routers.each do |router|
            router.ports.each do |port|
                devices << port if same_network?(port) && port.ip != @ip
            end
        end
        devices
    end

    def add_entry_to_arp_table(ip, mac)
        @arp_table.add_entry(ip, mac)
    end

    def send_icmp(data, destination, type)
        @destination = destination
        @current_data = data
        my_devices = devices_on_same_net
        if same_network?(destination)
            dest = destination
        else
            dest = default_gateway
        end
        mac = @arp_table.get_mac(dest.ip)
        if mac.nil?
            packet = ARPRequest.new(self, dest)
            puts packet.to_s
            response = nil
            my_devices.each do |myd|
                response = myd.receive_arp_request(self, dest)
                break unless response.nil?
            end
            @status = "WAITING_ARP_REPLY"
            receive_arp_reply(response.src, self)
            @status = "NONE"
        end
        data_packs = data.chars.each_slice(@mtu).map(&:join)
        requests = []
        data_packs.each_with_index do |pack, index|
            mf = index == data_packs.length-1 ? 0 : 1
            off = index*@mtu
            request = type.new(self, self, dest, destination, 8, mf, off, pack)
            puts request.to_s
            requests << request
        end
        dest.receive_icmp(requests)
        @current_data = ""
    end

    def receive_icmp(requests)
        @current_data = ""
        if requests[0].is_a?(ICMPTimeExceeded)
            exit
        end
        if requests[0].is_a?(ICMPEchoRequest)
            requests.each do |req|
                if req.mf == 0
                    @current_data += req.data
                    response = Received.new(self, @current_data)
                    puts response.to_s
                    break
                else
                    if req.off >= @current_data.length
                        @current_data += req.data
                    else
                        @current_data.insert(req.off, req.data)
                    end
                end
            end
            send_icmp(@current_data, requests[0].init_src, ICMPEchoReply)
        else
            requests.each do |req|
                if req.mf == 0
                    @current_data += req.data
                    response = Received.new(self, @current_data)
                    puts response.to_s
                    break
                else
                    if req.off >= @current_data.length
                        @current_data += req.data
                    else
                        @current_data.insert(req.off, req.data)
                    end
                end
            end
            exit
        end
    end

    def receive_arp_request(source, dest)
        if dest.ip == @ip
            @arp_table.add_entry(source.ip, source.mac)
            reply = ARPReply.new(self, source)
            puts reply.to_s
            return reply
        end
        return nil
    end

    def receive_arp_reply(source, dest)
        if @status == "WAITING_ARP_REPLY"
            @arp_table.add_entry(source.ip, source.mac)
        end
    end
end