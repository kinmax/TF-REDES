class Router
    attr_reader :name, :ports, :router_table, :arp_table

    def initialize(name, ports, router_table)
        @name = name
        @ports = ports
        @router_table = router_table
        @arp_table = ArpTable.new
    end
end