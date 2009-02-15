class CreateRuns < ActiveRecord::Migration
  def self.up
    create_table :runs do |t|
      t.integer :user_id
      t.datetime :date
      t.float :miles
      t.string :route
      t.timestamps
    end
  end

  def self.down
    drop_table :runs
  end
end

