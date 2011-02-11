require 'rubygems'
require 'logger'


class Tag
  include ActiveModel::Serializers::JSON
 
  attr_accessor :name
  
  def initialize(name)
    @name = name
  end
  
  def attributes
    @attributes ||= {'name' => 'nil'}
  end
  
  def self.find_by_user(user)
    #logger = Logger.new("log.txt")
    hydra = Typhoeus::Hydra.new
    all_tags  = []
 
    user.regist_services.each do |regist_service| 
      regist_service.get_tags(hydra) { |tags| all_tags << tags}
    end
 


    picasa_request = Typhoeus::Request.new(
      "http://picasaweb.google.com/data/feed/api/user/maguangjun?kind=tag")

    picasa_request.on_complete do |response|
      if response.code == 200
        doc = REXML::Document.new(response.body)
        titles = REXML::XPath.match(doc, "//entry//title").map {|x| x.text}
        titles.each { |title| tags << new(title)}
      elsif response.code == 404
        nil
      else
        raise response.body
      end
    end  
    hydra.queue(picasa_request)
    
    hydra.run
    #logger.info("model/tag:#{all_tags}")
    all_tags.uniq {|tag| tag.name}
  end
end