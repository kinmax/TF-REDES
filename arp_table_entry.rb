class ARPTableEntry
    attr_reader :ip, :mac

    def initialize(ip, mac)
        @ip = ip
        @mac = mac
    end
end