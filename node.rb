class Node
    attr_reader :name, :mac, :ip, :cidr, :mtu, :default_gateway, :arp_table

    def initialize(name, mac, ip, cidr, mtu, default_gateway)
        @name = name
        @mac = mac
        @ip = ip
        @cidr = cidr
        @mtu = mtu
        @default_gateway = default_gateway
        @arp_table = ARPTable.new
    end

    def same_network?(device)
        if @cidr != device.cidr
            return false
        end
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

    def add_entry_to_arp_table(ip, mac)
        @arp_table.add_entry(ip, mac)
    end
end