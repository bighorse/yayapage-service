require 'rubygems'
require 'typhoeus'
require 'json'
require 'logger'
require 'rexml/document'

class Service < ActiveRecord::Base
  validates_uniqueness_of :name

class FlickrService < Service
  def get_tags(hydra, &block)
    tags = []
    
    request = Typhoeus::Request.new(
      "http://api.flickr.com/services/rest/?method=flickr.tags.getListUser&api_key=f0de31f98fe2a16cbd81959d5144e525&user_id=29435289@N00&per_page=9999&format=json&nojsoncallback=1")

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

end