class User < ActiveRecord::Base
  has_many :user_service_relationships
  has_many :regist_services, :through => :user_service_relationships, :source => :service, :uniq => true
  validates_uniqueness_of :name, :email
  def to_json
    super(:except => :password)
  end

end