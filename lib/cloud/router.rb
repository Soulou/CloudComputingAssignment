module Cloud
  class Router
    def self.get(conn, subnet_id)
      public_id = conn.networks.select{|n| n.name == "public" }[0].id
      conn.list_routers.each do |r|
        if r.name == ROUTER_NAME
          puts "Use existing router #{ROUTER_NAME}"
          return r
        end
      end
      puts "Create new router #{ROUTER_NAME}"
      router = conn.create_router ROUTER_NAME, true
      puts "Create router interface to public network"
      conn.add_router_interface(router.id, subnet_id)
      conn.update_router(router.id, :external_gateway_info => { :network_id => public_id })
      return router
    end
  end
end
