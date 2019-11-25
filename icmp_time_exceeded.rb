class ICMPTimeExceeded
    attr_accessor :init_src, :src, :dst, :final_dst, :ttl, :mf, :off 

    def initialize(init_src, src, dst, final_dst, ttl, mf, off)
        @init_src = init_src
        @src = src
        @dst = dst
        @final_dst= final_dst
        @ttl = ttl
        @mf = mf
        @off = off
    end

    def to_s
        "#{@src.name} => #{@dst.name} : ETH (src=#{@src.mac} dst=#{@dst.mac}) \\n IP (src=#{@init_src.ip} dst=#{@final_dst.ip} ttl=#{@ttl} mf=#{@mf} off=#{@off}) \\n ICMP - Time Exceeded;"
    end
end