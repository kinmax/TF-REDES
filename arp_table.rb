class ArpTable
    attr_reader :entries

    def initialize
        @entries = []
    end

    def add_entry(ip, mac)
        new_entry = ArpTableEntry.new(ip, mac)
        @entries << new_entry
    end
end