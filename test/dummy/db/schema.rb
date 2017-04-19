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

ActiveRecord::Schema.define(version: 20160316211434) do

  create_table "large_text_fields", force: :cascade do |t|
    t.string  "field_name",                  null: false
    t.text    "value",      limit: 16777215
    t.integer "owner_id",                    null: false
    t.string  "owner_type",                  null: false
  end

  add_index "large_text_fields", ["owner_type", "owner_id", "field_name"], name: "large_text_field_by_owner_field", unique: true

  create_table "passports", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "travel_itineraries", force: :cascade do |t|
    t.string   "type"
    t.text     "aggregate_field"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
