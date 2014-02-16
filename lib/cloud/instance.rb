module Cloud
  class Instance
    $last_id = 0
    def initialize(conn, opts = {})
      @conn = conn
      if opts.has_key? :type and opts[:type] == "gateway"
        build_gateway opts
      else
        $last_id += 1
        build_instance $last_id
      end
    end

    private

    def build_gateway(opts)
      instance = build_instance 0
      puts "Wait VM to be ready to associate floating IP"
      while instance.status == "BUILD"
        instance.refresh
        print "."
        sleep 1
      end
      puts

      opts[:quantum].list_ports.each do |p|
        if p.device_id == instance.id and p.fixed_ips[0]["ip_address"] =~ /^192\.168.*/
          @port = p
          break
        end
      end

      # Not in the ruby-openstack gem
      data = JSON.generate({:floatingip => {:port_id => @port.id}})
      opts[:quantum].connection.req("PUT", "/floatingips/#{opts[:ip].id}", :data => data)

      return instance
    end

    def build_instance(index)
      image = get_image VM_IMAGE
      flavor = @conn.get_flavor FLAVOR_1GB
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
