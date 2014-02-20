module Cloud
  class Instance
    class << self
      def wait_all_active(conn, instances)
        # We destroy the array so a copy before is required
        instances = instances.clone
        seconds = 0
        vm_deleted = true
        while true
          if vm_deleted
            puts "\nWait for #{names(instances)} to be ACTIVE"
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
            puts "\nAll VMs are ACTIVE"
            break
          else
            if seconds > MAX_WAIT_TIME
              raise "Timeout for boot #{names(instances)}"
            end
            print "."
            seconds += 1
            sleep 1
          end
        end
      end

      def wait_all_ssh(conn, instances)
        instances = instances.clone
        seconds = 0
        vm_deleted = true
        while true
          if vm_deleted
            puts "\nWait SSH for #{names(instances)}"
            vm_deleted = false
          end

          instances.each do |i|
            begin
              Net::SSH.start(i.ip, "user", :password => "password") do |ssh| end
            rescue Net::SSH::AuthenticationFailed
              instances.delete(i)
              vm_deleted = true
            rescue
            end
          end
          if instances.length == 0
            puts "\nAll VMs are SSHable"
            break
          else
            if seconds > MAX_WAIT_TIME
              raise "Timeout for SSH #{names(instances)}"
            end
            print "."
            seconds += 1
            sleep 1
          end
        end
      end

      def wait_all_death(conn, instances)
        seconds = 0
        instances = instances.clone
        vm_deleted = true
        while true
          if vm_deleted
            puts "\nWait for #{names(instances)} shutdown"
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
            if seconds > MAX_WAIT_TIME
              raise "Timeout for shutdown #{names(instances)}"
            end
            print "."
            seconds += 1
            sleep 1
          end
        end
      end
    end
  end
end
