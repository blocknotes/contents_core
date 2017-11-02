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

ActiveRecord::Schema.define(version: 20171030182924) do

  create_table "contents_core_blocks", force: :cascade do |t|
    t.string "block_type", default: "text", null: false
    t.integer "version", default: 0, null: false
    t.string "name", default: "", null: false
    t.string "group"
    t.integer "position", default: 0, null: false
    t.boolean "published", default: true, null: false
    t.text "conf"
    t.integer "parent_id"
    t.string "parent_type"
    t.index ["parent_id", "parent_type"], name: "index_contents_core_blocks_on_parent_id_and_parent_type"
  end

  create_table "contents_core_items", force: :cascade do |t|
    t.string "type"
    t.string "name", default: "data", null: false
    t.integer "block_id"
    t.boolean "data_boolean"
    t.datetime "data_datetime"
    t.string "data_file"
    t.float "data_float"
    t.text "data_hash"
    t.integer "data_integer"
    t.string "data_string"
    t.text "data_text"
    t.index ["block_id"], name: "index_contents_core_items_on_block_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
