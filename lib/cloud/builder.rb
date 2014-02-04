module Cloud
  NETWORK_NAME = "s202926-net"
  SUBNET_NAME  = "s202926-subnet"
  SUBNET_RANGE = "192.168.111.111/24"
  DNS_NAMESERVER = "10.7.0.3"


  class EnvError < RuntimeError
  end
  
  class Builder
    def initialize(nb_instances)
      @nb_instances = nb_instances
      @router = nil
      @instances = []
   
      check_openstack_env
      @quantum = setup_connection "network"
      @network = create_network
      @subnetwork = create_subnetwork
    end
    
    def check_openstack_env
      %w(OS_USERNAME OS_PASSWORD OS_AUTH_URL OS_TENANT_NAME).each do |var|
        if ENV[var].nil?
          raise EnvError.new "ENV[#{var}] is undefined"
        end
      end
    end
    
    def setup_connection(type)
      c = OpenStack::Connection.create({
        :username => ENV["OS_USERNAME"],
        :password => ENV["OS_PASSWORD"],
        :auth_url => ENV["OS_AUTH_URL"],
        :authtenant_name => ENV["OS_TENANT_NAME"],
        :api_key => ENV["OS_PASSWORD"],
        :auth_method=> "password",
        :service_type=> type
      })
      c.connection.service_path = "/"
      return c
    end
    
    def create_network
      @quantum.networks.each do |n|
        return n if n.name == NETWORK_NAME
      end
      return @quantum.create_network NETWORK_NAME
    end
    
    def create_subnetwork
      @network.subnets.each do |s|
        subnet = @quantum.subnet s
        return subnet if subnet.name == SUBNET_NAME
      end
      return @quantum.create_subnet(
        @network.id,
        SUBNET_RANGE, 4,
        :name => SUBNET_NAME, :dns_nameservers => [DNS_NAMESERVER]
      )
    end
  end
end
