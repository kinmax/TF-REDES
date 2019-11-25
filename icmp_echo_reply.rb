class ICMPEchoReply
    attr_accessor :init_src, :src, :dst, :final_dst, :ttl, :mf, :off, :data 

    def initialize(init_src, src, dst, final_dst, ttl, mf, off, data)
        @init_src = init_src
        @src = src
        @dst = dst
        @final_dst= final_dst
        @ttl = ttl
        @mf = mf
        @off = off
        @data = data
    end

    def to_s
        "#{@src.name} => #{@dst.name} : ETH (src=#{@src.mac} dst=#{@dst.mac}) \\n IP (src=#{@init_src.ip} dst=#{@final_dst.ip} ttl=#{@ttl} mf=#{@mf} off=#{@off}) \\n ICMP - Echo reply (data=#{@data});"
    end
end