module Cloud
  class SecRule
    def initialize(conn, port)
      @conn = conn
      if port == "-1"
        proto = "icmp"
      else
        proto = "tcp"
      end

      @secgroup ||= default_secgroup
      @secgroup[:rules].each do |r|
        if r[:from_port].to_s == port
          puts "Rule #{proto} #{port} already exists"
          return
        end
      end
      @conn.create_security_group_rule(@secgroup[:id], {:ip_protocol => proto, :from_port => port, :to_port => port, :cidr=>"0.0.0.0/0" })
    end

    private

    def default_secgroup
      @conn.security_groups.each do |id, g|
        return g if g[:name] == "default"
      end
    end
  end
end
