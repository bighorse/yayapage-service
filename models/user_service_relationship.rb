class UserServiceRelationship < ActiveRecord::Base
  belongs_to :User
  belongs_to :Service
end