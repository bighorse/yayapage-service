require 'rubygems'
require 'typhoeus'
require 'json'
require 'logger'
require 'rexml/document'

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
    tags  = []
 
    flickr_request = Typhoeus::Request.new(
      "http://api.flickr.com/services/rest/?method=flickr.tags.getListUser&api_key=f0de31f98fe2a16cbd81959d5144e525&user_id=29435289@N00&per_page=9999&format=json&nojsoncallback=1")

    flickr_request.on_complete do |response|
      if response.code == 200
        tags_array = JSON.parse(response.body)["who"]["tags"]["tag"]
        tags_array.each { |item| tags << new(item["_content"])}
      elsif response.code == 404
        nil
      else
        raise response.body
      end
    end  
    hydra.queue(flickr_request)

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
    #logger.info("model/tag:#{tags}")
    tags.uniq {|tag| tag.name}
  end
end