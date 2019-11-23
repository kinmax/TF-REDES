class Received
    def initialize(node_name, data)
        @node_name = node_name
        @data = data
    end

    def to_s
        "#{node_name} rbox #{node_name} : Received #{data};"
    end
end