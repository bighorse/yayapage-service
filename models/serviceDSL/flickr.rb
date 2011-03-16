# filckr service

setup do
  @api_key = "f0de31f98fe2a16cbd81959d5144e525"
end

service "get_tags" do
  tags = []
  request "http://api.flickr.com/services/rest/?method=flickr.tags.getListUser&api_key=#{@api_key}&user_id=#{@userid}&per_page=9999&format=json&nojsoncallback=1" do
    @results["who"]["tags"]["tag"].each { |result| tags << Tag.new(result["_content"])}
  end
  tags
end
