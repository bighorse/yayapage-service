class Dsl 
  attr_accessor :type
  
  def setup(&block)
    @setups << block
  end
  
  def service(name, &block)
    @services[name.to_sym] = block
  end
  
  def request(url, &block)
    puts url
    @results = []
    self.instance_eval &block
  end
  
  def method_missing(method, *args, &block)
    File.open("models/serviceDSL/#{self.type}.rb") do |file|
      @setups = []
      @services = {}
      
      self.instance_eval file.read 
      
      hydra = args[0]
      @userid = args[1]
      @setups.each { |setup| self.instance_eval &setup }
      
      eval_result = self.instance_eval &@services[method]

      block.call(eval_result)
      
    end
    
  end
end

dsl = Dsl.new
dsl.type = "flickr"
puts dsl.get_tags("hydra", "yaya") { |tags| puts "tags = #{tags}"}