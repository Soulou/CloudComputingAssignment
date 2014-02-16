module Cloud
  NETWORK_NAME = ENV["NETWORK_NAME"] || "s202926-net"
  SUBNET_NAME  = ENV["SUBNET_NAME"] || "s202926-subnet"
  SUBNET_RANGE = ENV["SUBNET_RANGE"] || "192.168.111.0/24"
  DNS_NAMESERVER = ENV["DNS_NAMESERVER"] || "10.7.0.3"
  ROUTER_NAME = ENV["ROUTER_NAME"] || "s202926-router"
  PUB_KEY_FILE= ENV["PUB_KEY_FILE"] || "#{ENV["HOME"]}/.ssh/id_rsa.pub"
  KEYPAIR_NAME = ENV["KEYPAIR_NAME"] || "s202926-key"
  INSTANCE_PREFIX = ENV["INSTANCE_PREFIX"] || "s202926vm-"
  INSTANCE_FLAVOR = ENV["INSTANCE_FLAVOR"] || 2
  VM_IMAGE = ENV["VM_IMAGE"] || "ubuntu-precise"
  MAX_WAIT_TIME = ENV["MAX_WAIT_TIME"] || 60

  class EnvError < RuntimeError
  end
  
  class Builder
    def initialize
      @router = nil
      @instances = []
   
      check_openstack_env
      @quantum = setup_connection "network"

      @network = Network.new @quantum
      @subnetwork = SubNetwork.new @quantum, @network
      @tenant_id = @network.tenant_id
      @router = Router.new @quantum, @subnetwork

      @compute = setup_connection "compute"
    end

    def build(nb_instances)
      KeyPair.import @compute
      SecRule.new @compute, "-1"
      SecRule.new @compute, "22"
      @floating_ip = FloatingIp.get @compute
      @instances = []
      (0...nb_instances).each do
        @instances << Instance.new(@compute)
      end
      Instance.wait_all_boot(@compute, @instances)
      @instances[0].set_floating_ip(@quantum, @floating_ip)
      
      puts "Cluster is booting, public ip is #{@floating_ip.ip}"
    end
    
    def purge
      @instances = Instance.all @compute
      if @instances == nil or @instances.length == 0
        puts "No VM to destroy"
      end
      @instances.each do |i| i.delete end
      Instance.wait_all_death(@compute, @instances)
      @router.delete
      @subnetwork.delete
      @network.delete
    end

    private 

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
