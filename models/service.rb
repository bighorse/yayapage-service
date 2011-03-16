require 'rubygems'
require 'typhoeus'
require 'json'
require 'logger'
require 'rexml/document'

class Service 
  
  attr_accessor :hydra
  attr_accessor :type
  attr_accessor :service_userid
  
  def initialize(hydra, type, service_userid)
    self.hydra = hydra
    self.type = type
    self.service_userid = service_userid
    puts "type = #{type}"
  end
  
  def setup(&block)
    @setups << block
  end
  
  def service(name, &block)
    @services[name.to_sym] = block
  end
  
  def request(url, &block)
    @userid = self.service_userid
    @results = []
    
    request = Typhoeus::Request.new(url)

    request.on_complete do |response|
      if response.code == 200
        @results = JSON.parse(response.body)
      elsif response.code == 404
        nil
      else
        raise response.body
      end
      self.instance_eval &block
    end  
    
    self.hydra.queue(request)  
  end
  
  def method_missing(method, *args, &block)
    File.open("#{File.dirname(__FILE__)}/serviceDSL/#{self.type}.rb") do |file|
      @setups = []
      @services = {}
      
      self.instance_eval file.read 
      
      @setups.each { |setup| self.instance_eval &setup }
      
      eval_result = self.instance_eval &@services[method]

      block.call(eval_result)
    end
  end
end

# class FlickrService < Service
#   def get_tags(hydra, user, &block)
#     user_service = user.user_service_relationships.find_by_service_id(self)
#     tags = []
#     
#     request = Typhoeus::Request.new(
#       "http://api.flickr.com/services/rest/?method=flickr.tags.getListUser&api_key=#{self.api_key}&user_id=#{user_service.service_userid}&per_page=9999&format=json&nojsoncallback=1")
# 
#     request.on_complete do |response|
#       if response.code == 200
#         results = JSON.parse(response.body)["who"]["tags"]["tag"]
#         results.each { |result| tags << Tag.new(result["_content"])}
#       elsif response.code == 404
#         nil
#       else
#         raise response.body
#       end
#       block.call(tags)
#     end  
#     
#     hydra.queue(request)
#   end
# end
# 
# class PicasaService < Service
#   def get_tags(hydra, user, &block)
#     user_service = user.user_service_relationships.find_by_service_id(self)
#     tags = []
#     
#     request = Typhoeus::Request.new(
#       "http://picasaweb.google.com/data/feed/api/user/#{user_service.service_userid}?kind=tag")
# 
#     request.on_complete do |response|
#       if response.code == 200
#         doc = REXML::Document.new(response.body)
#         titles = REXML::XPath.match(doc, "//entry//title").map {|x| x.text}
#         titles.each { |title| tags << Tag.new(title)}
#       elsif response.code == 404
#         nil
#       else
#         raise response.body
#       end
#       block.call(tags)
#     end  
# 
#     hydra.queue(request)
#   end
# end
