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

ActiveRecord::Schema.define(version: 20150124094520) do

  create_table "cf_credits", force: true do |t|
    t.integer  "course_field_id"
    t.integer  "index",           default: 0
    t.integer  "credit_need",     default: 0
    t.string   "memo",            default: "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cf_credits", ["course_field_id"], name: "index_cf_credits_on_course_field_id", using: :btree

  create_table "cf_field_need", force: true do |t|
    t.integer  "course_field_id"
    t.integer  "field_need",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cm_cfships", force: true do |t|
    t.integer  "course_map_id"
    t.integer  "course_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cm_cfships", ["course_field_id"], name: "index_cm_cfships_on_course_field_id", using: :btree
  add_index "cm_cfships", ["course_map_id"], name: "index_cm_cfships_on_course_map_id", using: :btree

  create_table "colleges", force: true do |t|
    t.string   "name"
    t.string   "real_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_teachership_id"
    t.integer  "content_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["course_teachership_id"], name: "index_comments_on_course_teachership_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "content_list_ranks", force: true do |t|
    t.integer  "course_content_list_id"
    t.integer  "user_id"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_list_ranks", ["course_content_list_id"], name: "index_content_list_ranks_on_course_content_list_id", using: :btree
  add_index "content_list_ranks", ["user_id"], name: "index_content_list_ranks_on_user_id", using: :btree

  create_table "course_content_heads", force: true do |t|
    t.integer  "course_teachership_id"
    t.integer  "exam_record"
    t.integer  "homework_record"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
    t.integer  "course_rollcall"
  end

  add_index "course_content_heads", ["course_teachership_id"], name: "index_course_content_heads_on_course_teachership_id", using: :btree

  create_table "course_content_lists", force: true do |t|
    t.integer  "course_teachership_id"
    t.integer  "user_id"
    t.integer  "content_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_content_lists", ["course_teachership_id"], name: "index_course_content_lists_on_course_teachership_id", using: :btree
  add_index "course_content_lists", ["user_id"], name: "index_course_content_lists_on_user_id", using: :btree

  create_table "course_details", force: true do |t|
    t.integer "course_teachership_id"
    t.integer "department_id"
    t.integer "semester_id"
    t.string  "grade"
    t.string  "time"
    t.string  "room"
    t.string  "temp_cos_id"
    t.string  "cos_type"
    t.string  "brief"
    t.text    "memo"
    t.string  "reg_num"
    t.string  "students_limit"
    t.integer "view_times",            default: 0
  end

  add_index "course_details", ["course_teachership_id"], name: "index_new_course_details_on_course_teachership_id", using: :btree
  add_index "course_details", ["department_id"], name: "index_course_details_on_department_id", using: :btree
  add_index "course_details", ["semester_id"], name: "index_new_course_details_on_semester_id", using: :btree

  create_table "course_field_lists", force: true do |t|
    t.integer  "course_field_id"
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "record_type",     default: 1
    t.integer  "course_group_id"
  end

  create_table "course_field_selfships", force: true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_field_selfships", ["parent_id", "child_id"], name: "index_course_field_selfships_on_parent_id_and_child_id", using: :btree

  create_table "course_fields", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "credit_need", default: 0
    t.text     "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "field_type",  default: 0
  end

  create_table "course_group_lists", force: true do |t|
    t.integer  "course_group_id"
    t.integer  "course_id"
    t.integer  "user_id"
    t.integer  "lead",            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_groups", force: true do |t|
    t.integer  "user_id"
    t.integer  "gtype",         default: 0
    t.integer  "course_map_id", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_maps", force: true do |t|
    t.integer  "department_id"
    t.string   "name"
    t.text     "desc"
    t.integer  "semester_id"
    t.integer  "like"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "course_simulations", force: true do |t|
    t.integer  "user_id"
    t.integer  "semester_id"
    t.integer  "course_detail_id"
    t.integer  "course_field_id"
    t.string   "score"
    t.string   "memo"
    t.string   "memo2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "import_fail",      default: 0
    t.string   "cos_type",         default: ""
  end

  add_index "course_simulations", ["course_detail_id"], name: "index_course_simulations_on_course_detail_id", using: :btree
  add_index "course_simulations", ["course_field_id"], name: "index_course_simulations_on_course_field_id", using: :btree
  add_index "course_simulations", ["semester_id"], name: "index_course_simulations_on_semester_id", using: :btree
  add_index "course_simulations", ["user_id"], name: "index_course_simulations_on_user_id", using: :btree

  create_table "course_teacherships", force: true do |t|
    t.integer "course_id"
    t.string  "teacher_id"
  end

  add_index "course_teacherships", ["course_id"], name: "index_new_course_teacherships_on_course_id", using: :btree

  create_table "courses", force: true do |t|
    t.string   "real_id"
    t.string   "ch_name"
    t.string   "eng_name"
    t.integer  "credit"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: true do |t|
    t.integer  "degree"
    t.string   "dept_type"
    t.string   "dep_id"
    t.string   "ch_name"
    t.string   "eng_name"
    t.string   "use_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discuss_likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "discuss_id"
    t.integer  "sub_discuss_id"
    t.boolean  "like"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discuss_likes", ["discuss_id"], name: "index_discuss_likes_on_discuss_id", using: :btree
  add_index "discuss_likes", ["sub_discuss_id"], name: "index_discuss_likes_on_sub_discuss_id", using: :btree
  add_index "discuss_likes", ["user_id"], name: "index_discuss_likes_on_user_id", using: :btree

  create_table "discusses", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_teachership_id"
    t.integer  "likes"
    t.integer  "dislikes"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discusses", ["course_teachership_id"], name: "index_discusses_on_course_teachership_id", using: :btree
  add_index "discusses", ["user_id"], name: "index_discusses_on_user_id", using: :btree

  create_table "event_images", force: true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "img_file_name"
    t.string   "img_content_type"
    t.integer  "img_file_size"
    t.datetime "img_updated_at"
  end

  add_index "event_images", ["event_id"], name: "index_event_images_on_event_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "event_type"
    t.integer  "event_category_id"
    t.string   "title"
    t.string   "organization"
    t.text     "url"
    t.text     "content",           limit: 2147483647
    t.datetime "begin_time"
    t.datetime "end_time"
    t.integer  "user_id"
    t.integer  "location_id"
    t.integer  "likes"
    t.integer  "view_times"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["location_id"], name: "index_events_on_location_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "file_infos", force: true do |t|
    t.integer  "owner_id"
    t.integer  "course_teachership_id"
    t.integer  "semester_id"
    t.string   "description"
    t.integer  "download_times"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "new_course_teacher_ratings", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_teachership_id"
    t.integer  "score"
    t.integer  "rating_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "new_course_teacher_ratings", ["course_teachership_id"], name: "index_new_course_teacher_ratings_on_course_teachership_id", using: :btree
  add_index "new_course_teacher_ratings", ["user_id"], name: "index_new_course_teacher_ratings_on_user_id", using: :btree

  create_table "semesters", force: true do |t|
    t.string  "name"
    t.integer "year"
    t.integer "half"
  end

  create_table "sub_discusses", force: true do |t|
    t.integer  "user_id"
    t.integer  "discuss_id"
    t.integer  "likes"
    t.integer  "dislikes"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_discusses", ["discuss_id"], name: "index_sub_discusses_on_discuss_id", using: :btree

  create_table "teachers", force: true do |t|
    t.string   "real_id"
    t.string   "name"
    t.boolean  "is_deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "temp_course_simulations", force: true do |t|
    t.string   "student_id"
    t.string   "name"
    t.string   "dept"
    t.integer  "semester_id"
    t.integer  "course_detail_id"
    t.integer  "course_field_id"
    t.string   "score"
    t.string   "memo"
    t.string   "memo2"
    t.boolean  "has_added"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cos_type",         default: ""
  end

  create_table "user_coursemapships", force: true do |t|
    t.integer  "course_map_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_coursemapships", ["course_map_id"], name: "index_user_coursemapships_on_course_map_id", using: :btree
  add_index "user_coursemapships", ["user_id"], name: "index_user_coursemapships_on_user_id", using: :btree

  create_table "user_scores", force: true do |t|
    t.integer  "user_id",                                 null: false
    t.integer  "target_id",                               null: false
    t.integer  "course_field_id",             default: 0
    t.boolean  "is_agreed"
    t.text     "score",           limit: 255
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_scores", ["course_field_id"], name: "index_user_scores_on_course_field_id", using: :btree
  add_index "user_scores", ["target_id"], name: "index_user_scores_on_target_id", using: :btree
  add_index "user_scores", ["user_id"], name: "index_user_scores_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.integer  "semester_id"
    t.string   "activate_token"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
    t.string   "student_id"
    t.boolean  "agree",            default: false
    t.integer  "role",             default: 1,     null: false
  end

  add_index "users", ["department_id"], name: "index_users_on_department_id", using: :btree

end
