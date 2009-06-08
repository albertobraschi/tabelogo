class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops do |t|
      t.integer :rcd
      t.string :restaurant_name
      t.string :tabelog_url
      t.string :tabelog_mobile_url
      t.float :total_score
      t.float :taste_score
      t.float :service_score
      t.float :mood_score
      t.string :situation
      t.integer :dinner_price
      t.integer :lunch_price
      t.string :category
      t.integer :station_id
      t.string :address
      t.string :tel
      t.string :business_hours
      t.string :holiday
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end

  def self.down
    drop_table :shops
  end
end
