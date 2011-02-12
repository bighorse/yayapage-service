class CreateUserServiceRelationships < ActiveRecord::Migration
  def self.up
    create_table :user_service_relationships do |t|
      t.integer :user_id
      t.integer :service_id
      t.string :service_userid

      t.timestamps
    end
  end

  def self.down
    drop_table :user_service_relationships
  end
end
