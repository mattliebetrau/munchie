# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150623172539) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.string "phone_number"
    t.string "menu_url"
    t.string "identifier"
  end

  create_table "plan_users", force: :cascade do |t|
    t.integer "plan_id"
    t.text    "order"
    t.integer "user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.integer  "location_id"
    t.datetime "eta_at"
    t.integer  "user_id"
    t.float    "total"
  end

  create_table "users", force: :cascade do |t|
    t.string "slack_handle"
    t.string "venmo_handle"
  end

end
