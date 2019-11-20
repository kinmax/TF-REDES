class Node
    attr_reader :name, :mac, :ip, :cidr, :mtu, :default_gateway, :arp_table

    def initialize(name, mac, ip, cidr, mtu, default_gateway)
        @name = name
        @mac = mac
        @ip = ip
        @cidr = cidr
        @mtu = mtu
        @default_gateway = default_gateway
        @arp_table = ArpTable.new
    end
end