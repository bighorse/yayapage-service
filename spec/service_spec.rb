require File.dirname(__FILE__) + '/spec_helper'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

describe "service" do
  before(:each) do
    User.delete_all
    Service.delete_all
    UserServiceRelationship.delete_all
  end

  describe "GET on /api/v1/tag_list/users/:id" do
    before(:each) do
      user = User.create(
        :name => "yaya",
        :email => "yaya@yayapage.com",
        :password => "strongpass",
        :bio => "rubyist")
        
      fs = FlickrService.create(:api_key => "f0de31f98fe2a16cbd81959d5144e525")
      ps = PicasaService.create()
      
      user.user_service_relationships.create(:service => fs, :service_userid => "29435289@N00")
      user.user_service_relationships.create(:service => ps, :service_userid => "maguangjun")
    end

    it "should return tag list of the user" do
      get '/api/v1/tag_list/users/yaya'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes.size.should_not == 0
      attributes[0]["tag"]["name"].should == "beach"
      attributes.count {|x| x["tag"]["name"] == "beach"}.should == 1
    end

    it "should return a 404 for a user that doesn't exist" do
      get '/api/v1/tag_list/users/foo'
      last_response.status.should == 404
    end
  end
  
  describe "GET on /api/v1/users/:id" do
    before(:each) do
      User.create(
        :name => "paul",
        :email => "paul@pauldix.net",
        :password => "strongpass",
        :bio => "rubyist")
    end

    it "should return a user by name" do
      get '/api/v1/users/paul'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["name"].should == "paul"
    end

    it "should return a user with an email" do
      get '/api/v1/users/paul'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["email"].should == "paul@pauldix.net"
    end

    it "should not return a user's password" do
      get '/api/v1/users/paul'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes.should_not have_key("password")
    end

    it "should return a user with a bio" do
      get '/api/v1/users/paul'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["bio"].should == "rubyist"
    end

    it "should return a 404 for a user that doesn't exist" do
      get '/api/v1/users/foo'
      last_response.status.should == 404
    end
  end

  describe "POST on /api/v1/users" do
    it "should create a user" do
      post '/api/v1/users', {
          :name     => "trotter",
          :email    => "no spam",
          :password => "whatever",
          :bio      => "southern bell"}.to_json
      last_response.should be_ok
      get '/api/v1/users/trotter'
      attributes = JSON.parse(last_response.body)["user"]
      attributes["name"].should  == "trotter"
      attributes["email"].should == "no spam"
      attributes["bio"].should   == "southern bell"
    end
  end

  describe "PUT on /api/v1/users/:id" do
    it "should update a user" do
      User.create(
        :name => "bryan",
        :email => "no spam",
        :password => "whatever",
        :bio => "rspec master")
      put '/api/v1/users/bryan', {
        :bio => "testing freak"}.to_json
      last_response.should be_ok
      get '/api/v1/users/bryan'
      attributes = JSON.parse(last_response.body)["user"]
      attributes["bio"].should == "testing freak"
    end
  end

  describe "DELETE on /api/v1/users/:id" do
    it "should delete a user" do
      User.create(
        :name     => "francis",
        :email    => "no spam",
        :password => "whatever",
        :bio      => "williamsburg hipster")
      delete '/api/v1/users/francis'
      last_response.should be_ok
      get '/api/v1/users/francis'
      last_response.status.should == 404
    end
  end

  describe "POST on /api/v1/users/:id/sessions" do
    before(:each) do
      User.create(:name => "josh", :password => "nyc.rb rules")
    end

    it "should return the user object on valid credentials" do
      post '/api/v1/users/josh/sessions', {
        :password => "nyc.rb rules"}.to_json
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)["user"]
      attributes["name"].should == "josh"
    end

    it "should fail on invalid credentials" do
      post '/api/v1/users/josh/sessions', {
        :password => "wrong"}.to_json
      last_response.status.should == 400
    end
  end
end
