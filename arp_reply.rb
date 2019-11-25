class ARPReply
    attr_reader :src, :dst

    def initialize(src, dst)
        @src = src
        @dst = dst
    end

    def to_s
        "#{@src.name} => #{@dst.name} : ETH (src=#{@src.mac} dst=#{@dst.mac}) \\n ARP - #{@src.ip} is at #{@src.mac};"
    end
end