class ARPReply
    def initialize(src_name, dst_name, src_mac, dst_mac, src_ip, dst_ip)
        @src_name = src_name
        @dst_name = dst_name
        @src_mac = src_mac
        @dst_mac = dst_mac
        @src_ip = src_ip
        @dst_ip = dst_ip
    end

    def to_s
        "#{src_name} => #{dst_name} : ETH (src=#{src_mac} dst=#{dst_mac}) \n ARP - #{src_ip} is at #{src_mac};"
    end
end