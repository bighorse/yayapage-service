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

end