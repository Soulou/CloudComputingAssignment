module Cloud
  class Instance
    $last_id = 0

    def initialize(conn, opts = {})
      @conn = conn
      if opts.has_key? :instance
        @instance = opts[:instance]
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

    def self.wait_all_boot(conn, instances)
      # We destroy the array so a copy before is required
      instances = instances.clone
      vm_deleted = true
      while true
        if vm_deleted
          puts "\nWait for [#{instances.map(&:name).join(", ")}] boot"
          vm_deleted = false
        end

        instances.each do |i|
          if i.status == "ACTIVE"
            instances.delete(i)
            vm_deleted = true
          else
            i.refresh
          end
        end
        if instances.length == 0
          puts "\nAll VMs have successfuly boot"
          break
        else
          print "."
          sleep 1
        end
      end
    end

    def self.wait_all_death(conn, instances)
      # We destroy the array so a copy before is required
      instances = instances.clone
      vm_deleted = true
      while true
        if vm_deleted
          puts "\nWait for [#{instances.map(&:name).join(", ")}] shutdown"
          vm_deleted = false
        end

        instances.each do |i|
          begin
            i.refresh
          rescue OpenStack::Exception::ItemNotFound
            instances.delete(i)
            vm_deleted = true
          end
        end
        if instances.length == 0
          puts "\nAll VMs have been deleted"
          break
        else
          print "."
          sleep 1
        end
      end
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
    end

    private
    def build_instance(index)
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
