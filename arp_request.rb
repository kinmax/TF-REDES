class ARPRequest
    def initialize(src_name, src_mac, src_ip, dst_ip)
        @src_name = src_name
        @src_mac = src_mac
        @src_ip = src_ip
        @dst_ip = dst_ip
    end

    def to_s
        "#{src_name} box #{src_name} : ETH (src=#{src_mac} dst=FF:FF:FF:FF:FF:FF) \n ARP - Who has #{dst_ip}? Tell #{src_ip};"
    end
end