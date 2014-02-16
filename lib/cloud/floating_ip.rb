module Cloud
  class FloatingIp
    def self.get(conn)
      conn.get_floating_ips.each do |fip|
        if fip.instance_id.nil?
          puts "Use available floating IP #{fip.ip}"
          return fip
        end
      end
      fip = conn.create_floating_ip :pool => "public"
      puts "Query new floating IP: #{fip.ip}"
      return fip
    end
  end
end
