class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table   :users do |t|
      t.string     :name
      t.string     :email
      t.string     :crypted_password, :limit => 40
      t.string     :salt, :limit => 40
      t.string     :remember_token
      t.datetime   :remember_token_expires_at
      t.integer    :delete_flg, :limit => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

# script/generate scaffold User id:integer name:string email:string created_at:timestamp updated_at:timestamp