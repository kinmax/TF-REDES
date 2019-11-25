class ARPRequest
    attr_reader :src, :dst

    def initialize(src, dst)
        @src = src
        @dst = dst
    end

    def to_s
        "#{@src.name} box #{@src.name} : ETH (src=#{@src.mac} dst=FF:FF:FF:FF:FF:FF) \\n ARP - Who has #{@dst.ip}? Tell #{@src.ip};"
    end
end