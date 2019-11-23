class ICMPEchoReply
    def initialize(src_name, dst_name, src_mac, dst_mac, src_ip, dst_ip, ttl, mf, off, data)
        @src_name = src_name
        @dst_name = dst_name
        @src_mac = src_mac
        @dst_mac = dst_mac
        @src_ip = src_ip
        @dst_ip = dst_ip
        @ttl = ttl
        @mf = mf
        @off = off
        @data = data
    end

    def to_s
        "#{src_name} => #{dst_name} : ETH (src=#{src_mac} dst=#{dst_mac}) \n IP (src=#{src_ip} dst=#{dst_ip} ttl=#{ttl} mf=#{mf} off=#{off}) \n ICMP - Echo reply (data=#{data});"
    end
end