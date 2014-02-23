module Cloud
  class Instance
    $last_id = 0

    attr_reader :ip

    def initialize(conn, opts = {})
      @conn = conn
      if opts.has_key? :instance
        @instance = opts[:instance]
        if @instance.addresses.length > 0
	  @ip = @instance.addresses.last.address
        end
      else
        $last_id += 1
        @instance = build_instance $last_id
      end
    end

    def delete
      @instance.delete!
    end

    def method_missing(*args)
      @instance.send args[0]
    end

    def self.names(instances)
      "[#{instances.map(&:name).join(", ")}]"
    end

    def self.all(conn)
      conn.list_servers.select{ |s|
        s[:name] =~ /^#{INSTANCE_PREFIX}.*/
      }.map{ |s|
        self.new conn, instance: OpenStack::Compute::Server.new(conn, s[:id])
      }
    end

    def set_floating_ip(quantum, ip)
      quantum.list_ports.each do |p|
        if p.device_id == @instance.id and p.fixed_ips[0]["ip_address"] =~ /^192\.168.*/
          @port = p
          break
        end
      end

      # Not in the ruby-openstack gem
      data = JSON.generate({:floatingip => {:port_id => @port.id}})
      quantum.connection.req("PUT", "/floatingips/#{ip.id}", :data => data)
      @ip = ip.ip
    end

    private
    def build_instance(index)
      if $last_id == 10
        puts "Wait 1 minute to avoid OverLimit error"
        sleep 60
      end
      image = get_image VM_IMAGE
      flavor = @conn.get_flavor INSTANCE_FLAVOR
      name = "#{INSTANCE_PREFIX}#{index}"
      inst = @conn.create_server({
        :name => name,
        :imageRef => image[:id],
        :flavorRef => flavor.id,
        :key_name => KEYPAIR_NAME,
        :security_groups => ["default"]
      })
      puts "Create VM #{name}"
      return inst
    end

    def get_image(name)
      @conn.list_images.each do |i|
        if i[:name] == name
          return i
        end
      end
      raise "Image #{VM_IMAGE} not found"
    end
  end
end
