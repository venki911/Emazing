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

ActiveRecord::Schema.define(version: 20140425205918) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "daily_reports", force: true do |t|
    t.date "created_at"
    t.text "body"
  end

  create_table "ga_accounts", force: true do |t|
    t.string   "account_id"
    t.string   "custom_data_source_id"
    t.string   "web_property_id"
    t.string   "view_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ga_exports", force: true do |t|
    t.string   "profile_id"
    t.date     "start_date"
    t.date     "end_date"
    t.hstore   "ga_data"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
