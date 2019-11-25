class RouterPort
    attr_reader :mac, :ip, :cidr, :mtu, :name, :router

    def initialize(mac, ip, cidr, mtu, name)
        @mac = mac
        @ip = ip
        @cidr = cidr
        @mtu = mtu
        @name = name
        @status = "NONE"
    end

    def define_router(router)
        @router = router
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

    def receive_arp_request(source, dest)
        if dest.ip == @ip
            @router.add_entry_to_arp_table(source.ip, source.mac)
            reply = ARPReply.new(self, source)
            puts reply.to_s
            return reply
        end
        return nil
    end

    def receive_arp_reply(source, dest)
        if @status == "WAITING_ARP_REPLY"
            @router.add_entry_to_arp_table(source.ip, source.mac)
        end
    end

    def receive_icmp(requests)
        @router.receive_icmp(requests)
    end

    def send_icmp(requests, next_hop = nil, type)
        if next_hop.nil?
            dest = requests[0].final_dst
        else            
            @routers.each do |r|
                r.ports.each do |p|
                    if p.ip == next_hop
                        dest = p
                    end
                end
            end
            raise Exception if dest.nil?
        end

        mac = @router.arp_table.get_mac(dest.ip)
        my_devices = devices_on_same_net
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
        myreqs = []
        if type == ICMPTimeExceeded
            requests.each do |req|
                request = type.new(req.init_src, self, dest, req.final_dst, req.ttl, 0, 0)
                puts request.to_s
                myreqs << request
            end
        else
            requests.each do |req|
                data_packs = req.data.chars.each_slice(@mtu).map(&:join)
                data_packs.each_with_index do |pack, index|
                    mf = index == data_packs.length-1 && req.mf == 0 ? 0 : 1
                    off = index*@mtu + req.off
                    request = type.new(req.init_src, self, dest, req.final_dst, req.ttl, mf, off, pack)
                    puts request.to_s
                    myreqs << request
                end
            end
        end
        dest.receive_icmp(myreqs)
    end
end