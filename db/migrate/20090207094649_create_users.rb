class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, :name, :email, :limit => 255
      t.string  :password, :email_hash, :limit => 64
      t.integer :fb_uid
      t.timestamps
    end
    add_index :users, :username, :name => "users_name_index", :uniq => true
  end

  def self.down
    remove_index :users, :name => "users_name_index"
    drop_table :users
  end
end
