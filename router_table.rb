class RouterTable
    attr_reader :entries

    def initialize
        @entries = []
    end

    def add_entry(cidr, ip, next_hop, port)
        new_entry = RouterTableEntry.new(cidr, ip, next_hop, port)
        @entries << new_entry
    end
end