# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090608114332) do

  create_table "requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shop_id"
    t.integer  "station_id"
    t.string   "category"
    t.integer  "delete_flg", :limit => 1
    t.integer  "rate",       :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shops", :force => true do |t|
    t.integer  "rcd"
    t.string   "restaurant_name"
    t.string   "tabelog_url"
    t.string   "tabelog_mobile_url"
    t.float    "total_score"
    t.float    "taste_score"
    t.float    "service_score"
    t.float    "mood_score"
    t.string   "situation"
    t.integer  "dinner_price"
    t.integer  "lunch_price"
    t.string   "category"
    t.integer  "station_id"
    t.string   "address"
    t.string   "tel"
    t.string   "business_hours"
    t.string   "holiday"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "delete_flg",                :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
