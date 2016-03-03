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

ActiveRecord::Schema.define(version: 20160227134520) do

  create_table "agreed_scores", force: true do |t|
    t.integer "user_id",         default: 0,    null: false
    t.integer "course_id",       default: 0,    null: false
    t.integer "course_field_id", default: 0,    null: false
    t.string  "cos_type",        default: "",   null: false
    t.string  "score",           default: "通過", null: false
    t.string  "memo",            default: "",   null: false
  end

  add_index "agreed_scores", ["course_id"], name: "index_agreed_scores_on_course_id", using: :btree
  add_index "agreed_scores", ["user_id"], name: "index_agreed_scores_on_user_id", using: :btree

  create_table "attendances", force: true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendances", ["event_id"], name: "index_attendances_on_event_id", using: :btree
  add_index "attendances", ["user_id"], name: "index_attendances_on_user_id", using: :btree

  create_table "auth_e3s", force: true do |t|
    t.integer  "user_id"
    t.string   "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_facebooks", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "book_trade_info_ctsships", force: true do |t|
    t.integer  "book_trade_info_id"
    t.integer  "course_teachership_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_trade_info_ctsships", ["book_trade_info_id"], name: "index_book_trade_info_ctsships_on_book_trade_info_id", using: :btree
  add_index "book_trade_info_ctsships", ["course_teachership_id"], name: "index_book_trade_info_ctsships_on_course_teachership_id", using: :btree

  create_table "book_trade_infos", force: true do |t|
    t.integer  "book_id",            default: 0,  null: false
    t.integer  "user_id",            default: 0,  null: false
    t.integer  "contact_way",        default: 0,  null: false
    t.string   "book_name",          default: "", null: false
    t.integer  "price",              default: 0,  null: false
    t.integer  "status",             default: 0,  null: false
    t.integer  "view_times",         default: 0,  null: false
    t.text     "desc",                            null: false
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_trade_infos", ["book_id"], name: "index_book_trade_infos_on_book_id", using: :btree
  add_index "book_trade_infos", ["user_id"], name: "index_book_trade_infos_on_user_id", using: :btree

  create_table "books", force: true do |t|
    t.boolean  "from_google",  default: false, null: false
    t.string   "title",        default: "",    null: false
    t.string   "isbn"
    t.string   "authors"
    t.text     "description"
    t.text     "image_link"
    t.text     "preview_link"
    t.integer  "user_id",      default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["user_id"], name: "index_books_on_user_id", using: :btree

  create_table "bulletins", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "article"
    t.boolean  "article_type"
    t.datetime "created_at"
    t.datetime "updated_at"
<<<<<<< HEAD
    t.string   "update_user"
    t.boolean  "hidden_type",  default: false, null: false
=======
>>>>>>> 863169c68f53652be711b4027a8db7d5682d3f3e
  end

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

  add_index "cf_field_need", ["course_field_id"], name: "index_cf_field_need_on_course_field_id", using: :btree

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
    t.integer  "course_teachership_id"
    t.integer  "department_id",                     null: false
    t.integer  "semester_id"
    t.string   "grade"
    t.string   "time"
    t.string   "room"
    t.string   "temp_cos_id"
    t.string   "cos_type"
    t.string   "brief"
    t.text     "memo"
    t.string   "reg_num"
    t.string   "students_limit"
    t.integer  "view_times",            default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_details", ["course_teachership_id"], name: "index_new_course_details_on_course_teachership_id", using: :btree
  add_index "course_details", ["department_id"], name: "index_course_details_on_department_id", using: :btree
  add_index "course_details", ["semester_id"], name: "index_new_course_details_on_semester_id", using: :btree

  create_table "course_field_lists", force: true do |t|
    t.integer  "course_field_id"
    t.integer  "course_id"
    t.integer  "course_group_id"
    t.string   "grade",           default: "*"
    t.string   "half",            default: "*"
    t.boolean  "record_type",     default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_field_lists", ["course_field_id"], name: "index_course_field_lists_on_course_field_id", using: :btree
  add_index "course_field_lists", ["course_group_id"], name: "index_course_field_lists_on_course_group_id", using: :btree
  add_index "course_field_lists", ["course_id"], name: "index_course_field_lists_on_course_id", using: :btree
  add_index "course_field_lists", ["user_id"], name: "index_course_field_lists_on_user_id", using: :btree

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

  add_index "course_fields", ["user_id"], name: "index_course_fields_on_user_id", using: :btree

  create_table "course_group_lists", force: true do |t|
    t.integer  "course_group_id"
    t.integer  "course_id"
    t.integer  "user_id"
    t.integer  "lead",            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_group_lists", ["course_group_id"], name: "index_course_group_lists_on_course_group_id", using: :btree
  add_index "course_group_lists", ["course_id"], name: "index_course_group_lists_on_course_id", using: :btree
  add_index "course_group_lists", ["user_id"], name: "index_course_group_lists_on_user_id", using: :btree

  create_table "course_groups", force: true do |t|
    t.integer  "user_id"
    t.integer  "gtype",         default: 0
    t.integer  "course_map_id", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_groups", ["course_map_id"], name: "index_course_groups_on_course_map_id", using: :btree
  add_index "course_groups", ["user_id"], name: "index_course_groups_on_user_id", using: :btree

  create_table "course_maps", force: true do |t|
    t.integer  "department_id"
    t.string   "name"
    t.text     "desc",                      null: false
    t.integer  "year"
    t.integer  "total_credit",  default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "course_maps", ["department_id"], name: "index_course_maps_on_department_id", using: :btree
  add_index "course_maps", ["user_id"], name: "index_course_maps_on_user_id", using: :btree

  create_table "course_teacher_ratings", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_teachership_id"
    t.integer  "score"
    t.integer  "rating_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_teacher_ratings", ["course_teachership_id"], name: "index_new_course_teacher_ratings_on_course_teachership_id", using: :btree
  add_index "course_teacher_ratings", ["user_id"], name: "index_new_course_teacher_ratings_on_user_id", using: :btree

  create_table "course_teacherships", force: true do |t|
    t.integer "course_id"
    t.string  "teacher_id"
  end

  add_index "course_teacherships", ["course_id"], name: "index_new_course_teacherships_on_course_id", using: :btree
  add_index "course_teacherships", ["teacher_id"], name: "index_course_teacherships_on_teacher_id", using: :btree

  create_table "courses", force: true do |t|
    t.string   "real_id"
    t.string   "ch_name"
    t.string   "eng_name"
    t.integer  "credit"
    t.boolean  "is_virtual", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: true do |t|
    t.integer  "degree"
    t.string   "dept_type"
    t.string   "dep_id"
    t.integer  "college_id",  default: 0
    t.string   "ch_name"
    t.string   "eng_name"
    t.boolean  "has_courses", default: false
    t.boolean  "majorable",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["college_id"], name: "index_departments_on_college_id", using: :btree

  create_table "discusses", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_teachership_id"
    t.string   "title"
    t.text     "content"
    t.boolean  "is_anonymous",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discusses", ["course_teachership_id"], name: "index_discusses_on_course_teachership_id", using: :btree
  add_index "discusses", ["user_id"], name: "index_discusses_on_user_id", using: :btree

  create_table "event_follows", force: true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_follows", ["event_id"], name: "index_event_follows_on_event_id", using: :btree
  add_index "event_follows", ["user_id"], name: "index_event_follows_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "event_type"
    t.string   "title",                                                  null: false
    t.string   "organization"
    t.string   "location",                                               null: false
    t.string   "lat_long"
    t.string   "url",                 limit: 2083
    t.text     "content",             limit: 2147483647,                 null: false
    t.datetime "begin_time",                                             null: false
    t.datetime "end_time",                                               null: false
    t.integer  "user_id",                                                null: false
    t.integer  "view_times",                             default: 0,     null: false
    t.integer  "event_follows_count",                    default: 0
    t.integer  "attendances_count",                      default: 0
    t.boolean  "banner",                                 default: false
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "global_variables", force: true do |t|
    t.string   "data"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "normal_scores", force: true do |t|
    t.integer "user_id",          default: 0,  null: false
    t.integer "course_detail_id", default: 0,  null: false
    t.integer "course_field_id",  default: 0,  null: false
    t.string  "cos_type",         default: "", null: false
    t.string  "score",            default: "", null: false
  end

  add_index "normal_scores", ["course_detail_id"], name: "index_normal_scores_on_course_detail_id", using: :btree
  add_index "normal_scores", ["course_field_id"], name: "index_normal_scores_on_course_field_id", using: :btree
  add_index "normal_scores", ["user_id"], name: "index_normal_scores_on_user_id", using: :btree

  create_table "past_exams", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_teachership_id"
    t.integer  "semester_id"
    t.boolean  "is_anonymous",          default: false
    t.string   "description"
    t.integer  "download_times"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "past_exams", ["course_teachership_id"], name: "index_past_exams_on_course_teachership_id", using: :btree
  add_index "past_exams", ["semester_id"], name: "index_past_exams_on_semester_id", using: :btree
  add_index "past_exams", ["user_id"], name: "index_past_exams_on_user_id", using: :btree

  create_table "semesters", force: true do |t|
    t.string  "name"
    t.integer "year"
    t.integer "half"
  end

  create_table "sub_discusses", force: true do |t|
    t.integer  "user_id"
    t.integer  "discuss_id"
    t.text     "content"
    t.boolean  "is_anonymous", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_discusses", ["discuss_id"], name: "index_sub_discusses_on_discuss_id", using: :btree
  add_index "sub_discusses", ["user_id"], name: "index_sub_discusses_on_user_id", using: :btree

  create_table "teachers", force: true do |t|
    t.string   "real_id"
    t.string   "name"
    t.boolean  "is_deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_collections", force: true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.integer  "semester_id"
    t.string   "name",        default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_coursemapships", force: true do |t|
    t.integer  "course_map_id"
    t.integer  "user_id"
    t.integer  "need_update",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_coursemapships", ["course_map_id"], name: "index_user_coursemapships_on_course_map_id", using: :btree
  add_index "user_coursemapships", ["user_id"], name: "index_user_coursemapships_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.integer  "year",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
    t.boolean  "agree",                  default: false
    t.boolean  "agree_share",            default: true
    t.integer  "role",                   default: 1
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["department_id"], name: "index_users_on_department_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
