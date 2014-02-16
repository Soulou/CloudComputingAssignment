module Cloud
  NETWORK_NAME = "s202926-net"
  SUBNET_NAME  = "s202926-subnet"
  SUBNET_RANGE = "192.168.111.0/24"
  DNS_NAMESERVER = "10.7.0.3"
  ROUTER_NAME = "s202926-router"
  PUB_KEY_FILE="#{ENV["HOME"]}/.ssh/id_rsa.pub"
  KEYPAIR_NAME = "s202926-key"
  INSTANCE_PREFIX = "s202926vm-"
  FLAVOR_1GB = 2
  VM_IMAGE = "ubuntu-precise"

  class EnvError < RuntimeError
  end
  
  class Builder
    def initialize(nb_instances)
      @nb_instances = nb_instances
      @router = nil
      @instances = []
   
      check_openstack_env
      @quantum = setup_connection "network"
      @network = Network.get @quantum
      @subnetwork = SubNetwork.get @quantum, @network
      @tenant_id = @network.tenant_id
      @router = Router.get @quantum, @subnetwork.id

      @compute = setup_connection "compute"
      KeyPair.import @compute
      SecRule.new @compute, "-1"
      SecRule.new @compute, "22"
      @floating_ip = FloatingIp.get @compute

      @gateway_instance = Instance.new(
        @compute, {
          :quantum => @quantum,
          :type => "gateway", 
          :ip => @floating_ip
        }
      )
      (1...nb_instances).each do
        Instance.new @compute
      end
      
      puts "Cluster is booting, public ip is #{@floating_ip.ip}"
    end
    
    def check_openstack_env
      puts "Validation of the Openstack environment variables"
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
      if type == "compute"
        c.connection.service_path = "/v2/#{@tenant_id}"
      end
      return c
    end
  end
end
