class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :user_id
      t.integer :shop_id
      t.integer :station_id
      t.string  :category
      t.integer :delete_flg, :limit => 1
      t.integer :rate, :limit => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
