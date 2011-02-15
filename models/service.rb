require 'rubygems'
require 'typhoeus'
require 'json'
require 'logger'
require 'rexml/document'

class Service < ActiveRecord::Base
  has_many :user_service_relationships
  has_many :users, :through => :user_service_relationships, :source => :user
  
end

class FlickrService < Service
  def get_tags(hydra, user, &block)
    user_service = user.user_service_relationships.find_by_service_id(self)
    tags = []
    
    request = Typhoeus::Request.new(
      "http://api.flickr.com/services/rest/?method=flickr.tags.getListUser&api_key=#{self.api_key}&user_id=#{user_service.service_userid}&per_page=9999&format=json&nojsoncallback=1")

    request.on_complete do |response|
      if response.code == 200
        results = JSON.parse(response.body)["who"]["tags"]["tag"]
        results.each { |result| tags << Tag.new(result["_content"])}
      elsif response.code == 404
        nil
      else
        raise response.body
      end
      block.call(tags)
    end  
    
    hydra.queue(request)
  end
end

class PicasaService < Service
  def get_tags(hydra, user, &block)
    user_service = user.user_service_relationships.find_by_service_id(self)
    tags = []
    
    request = Typhoeus::Request.new(
      "http://picasaweb.google.com/data/feed/api/user/#{user_service.service_userid}?kind=tag")

    request.on_complete do |response|
      if response.code == 200
        doc = REXML::Document.new(response.body)
        titles = REXML::XPath.match(doc, "//entry//title").map {|x| x.text}
        titles.each { |title| tags << Tag.new(title)}
      elsif response.code == 404
        nil
      else
        raise response.body
      end
      block.call(tags)
    end  

    hydra.queue(request)
  end
end
