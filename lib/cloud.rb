
dir = File.dirname __FILE__
Dir["#{dir}/cloud/*.rb"].each do |f| require f end
