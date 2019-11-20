class Network
    attr_reader :nodes, :routers

    def initialize(nodes, routes)
        @nodes = nodes
        @routers = routers
    end
end