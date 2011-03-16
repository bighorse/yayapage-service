class User < ActiveRecord::Base
  has_many :regist_services
  validates_uniqueness_of :name, :email
  def to_json
    super(:except => :password)
  end

end