require File.dirname(__FILE__) + '/tag'

class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email
  def to_json
    super(:except => :password)
  end
  
  def tags
    Tag.find_by_user(self)
  end
end