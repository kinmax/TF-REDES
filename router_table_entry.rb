class RouterTableEntry
    attr_reader :cidr, :ip, :next_hop, :port

    def initialize(cidr, ip, next_hop, port)
        @cidr = cidr
        @ip = ip
        @next_hop = next_hop
        @port = port
    end
end