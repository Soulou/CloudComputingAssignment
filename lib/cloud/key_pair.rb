module Cloud
  class KeyPair
    def self.import(connection)
      connection.keypairs.each do |id, key|
        if key[:name] == KEYPAIR_NAME
          puts "Use existing keypair #{KEYPAIR_NAME}"
          return
        end
      end
      puts "Create new keypair #{KEYPAIR_NAME}"
      connection.create_keypair :tenant_id => ENV["OS_TENANT_NAME"], :name => KEYPAIR_NAME, :public_key => read_key
    end

    private 
    def self.read_key
      raise "#{PUB_KEY_FILE} not found" unless File.exists? PUB_KEY_FILE
      File.read PUB_KEY_FILE
    end
  end
end
