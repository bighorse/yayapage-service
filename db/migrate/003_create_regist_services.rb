class CreateRegistServices < ActiveRecord::Migration
  def self.up
    create_table :regist_services do |t|
      t.integer :user_id
      t.string :type
      t.string :service_userid

      t.timestamps
    end
  end

  def self.down
    drop_table :regist_services
  end
end
