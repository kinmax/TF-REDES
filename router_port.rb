class RouterPort
    attr_reader :mac, :ip, :cidr, :mtu

    def initialize(mac, ip, cidr, mtu)
        @mac = mac
        @ip = ip
        @cidr = cidr
        @mtu = mtu
    end
end