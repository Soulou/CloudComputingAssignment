module Cloud
  class Network
    def initialize(conn)
      @conn = conn
      @conn.networks.each do |n|
        if n.name == NETWORK_NAME
          puts "Use existing network #{NETWORK_NAME}"
          @network = n
          return
        end
      end
      puts "Create new network #{NETWORK_NAME}"
      @network = @conn.create_network NETWORK_NAME
    end

    def delete
      puts "Delete network #{@network.name}"
      @conn.delete_network(@network.id)
    end

    def id
      @network.id
    end
    def tenant_id
      @network.tenant_id
    end
  end
  
  class SubNetwork  
    def initialize(conn, net)
      @conn = conn
      @conn.subnets.each do |s|
        if s.name == SUBNET_NAME
          puts "Use existing sub-network #{SUBNET_NAME}"
          @subnet = s
          return
        end
      end
      puts "Create new sub-network #{SUBNET_NAME}"
      @subnet = @conn.create_subnet(
        net.id,
        SUBNET_RANGE, 4,
        :name => SUBNET_NAME, :dns_nameservers => [DNS_NAMESERVER]
      )
    end

    def delete
      puts "Delete subnet #{@subnet.name}"
      @conn.delete_subnet(@subnet.id)
    end

    def id
      @subnet.id
    end
  end
end
