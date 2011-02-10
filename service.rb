require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'sinatra'
require 'logger'
require "#{File.dirname(__FILE__)}/models/user"

# setting up our environment
# logger = Logger.new("log.txt")
# env_arg = ARGV.index("-e")
# env_argv = ARGV[env_arg+1] if env_arg
# env = env_argv || ENV["RACK_ENV"] || "development"
# logger.info("#{env}")
# databases = YAML.load_file("config/database.yml")
# ActiveRecord::Base.establish_connection(databases[env])
configure :production do
  # Configure stuff here you'll want to
  # only be run at Heroku at boot

  # TIP:  You can get you database information
  #       from ENV['DATABASE_URI'] (see /env route below)
  databases = YAML.load_file("config/database.yml")
  ActiveRecord::Base.establish_connection(databases[ENV["RACK_ENV"]])
end
# the HTTP entry points to our service
get '/env' do
  ENV.inspect
end

# get tag list by user
get '/api/v1/tag_list/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    #logger.info("service:#{user.tags.to_json}")
    user.tags.to_json
  else
    error 404, "user not found".to_json
  end
end

# get a user by name
get '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.to_json
  else
    error 404, "user not found".to_json
  end
end

# create a new user
post '/api/v1/users' do
  begin
    user = User.create(JSON.parse(request.body.read))
    if user
      user.to_json
    else
      error 400, "" # do nothing for now. we'll cover later
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# update an existing user
put '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    begin
      user.update_attributes(JSON.parse(request.body.read))
      # we don't have any validations right now. we'll cover later
      user.to_json
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 404, "user not found".to_json
  end
end

# destroy an existing user
delete '/api/v1/users/:name' do
  user = User.find_by_name(params[:name])
  if user
    user.destroy
    user.to_json
  else
    error 404, "user not found".to_json
  end
end

# verify a user name and password
post '/api/v1/users/:name/sessions' do
  begin
    attributes = JSON.parse(request.body.read)
    user = User.find_by_name_and_password(
      params[:name], attributes["password"])
    if user
      user.to_json
    else
      error 400, "invalid login credentials".to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end