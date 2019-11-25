class ARPTable
    attr_reader :entries

    def initialize
        @entries = []
    end

    def add_entry(ip, mac)
        new_entry = ARPTableEntry.new(ip, mac)
        @entries << new_entry
    end

    def get_mac(ip)
        @entries.each do |entry|
            if entry.ip == ip
                return entry.mac
            end
        end
        return nil
    end
end