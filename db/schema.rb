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

ActiveRecord::Schema.define(version: 20140415121828) do

  create_table "courses", force: true do |t|
    t.string   "ch_name"
    t.string   "eng_name"
    t.integer  "grade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_infos", force: true do |t|
    t.integer  "owner_id"
    t.integer  "course_id"
    t.integer  "size"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "types"
    t.string   "description"
  end

  add_index "file_infos", ["course_id"], name: "index_file_infos_on_course_id", using: :btree
  add_index "file_infos", ["owner_id"], name: "index_file_infos_on_owner_id", using: :btree

  create_table "grades", force: true do |t|
    t.string "name"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "grade_id"
    t.integer  "activated"
    t.string   "activate_token"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
