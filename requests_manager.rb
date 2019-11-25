class RequestsManager
    def initialize(nodes, routers, source, destination, message)
        @nodes = nodes
        @routers = routers
        @source = source
        @destination = destination
        @message = message
        @requests_list = []
    end

    def make_requests
        @source.send_icmp(@message, @destination, ICMPEchoRequest)           
    end

    def devices_in_same_net(device)
        devices = []
        @nodes.each do |node|
            devices << node if device.same_network?(node.ip) && device.mac != node.mac
        end
        @routers.each do |router|
            router.ports.each do |port|
                devices << [router, port] if device.same_network?(port.ip) && device.mac != port.mac
            end
        end
        return devices
    end

    def get_device_by_ip(ip)
        nodes.each do |node|
            return node if node.ip == ip
        end
        routers.each do |router|
            router.ports.each do |port|
                return [router, port] if port.ip == ip
            end
        end
    end
end