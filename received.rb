class Received
    attr_reader :node, :data

    def initialize(node, data)
        @node = node
        @data = data
    end

    def to_s
        "#{@node.name} rbox #{@node.name} : Received #{@data};"
    end
end