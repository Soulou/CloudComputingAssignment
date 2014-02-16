module Cloud
  class Network
    def self.get(conn)
      conn.networks.each do |n|
        if n.name == NETWORK_NAME
          puts "Use existing network #{NETWORK_NAME}"
          return n
        end
      end
      puts "Create new network #{NETWORK_NAME}"
      return conn.create_network NETWORK_NAME
    end
  end
  
  class SubNetwork  
    def self.get(conn, net)
      conn.subnets.each do |s|
        if s.name == SUBNET_NAME
          puts "Use existing sub-network #{SUBNET_NAME}"
          return s
        end
      end
      puts "Create new sub-network #{SUBNET_NAME}"
      return conn.create_subnet(
        net.id,
        SUBNET_RANGE, 4,
        :name => SUBNET_NAME, :dns_nameservers => [DNS_NAMESERVER]
      )
    end
  end
end
