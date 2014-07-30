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

ActiveRecord::Schema.define(version: 20140730074138) do

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

  create_table "content_list_ranks", force: true do |t|
    t.integer  "raider_content_list_id"
    t.integer  "user_id"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_details", force: true do |t|
    t.integer  "course_teachership_id"
    t.integer  "semester_id"
    t.string   "time"
    t.string   "room"
    t.string   "temp_cos_id"
    t.string   "brief"
    t.text     "memo"
    t.string   "reg_num"
    t.string   "students_limit"
    t.string   "cos_type"
    t.string   "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_details", ["course_teachership_id"], name: "index_course_details_on_course_teachership_id", using: :btree
  add_index "course_details", ["semester_id"], name: "index_course_details_on_semester_id", using: :btree

  create_table "course_managers", force: true do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_managers", ["department_id"], name: "index_course_managers_on_department_id", using: :btree
  add_index "course_managers", ["user_id"], name: "index_course_managers_on_user_id", using: :btree

  create_table "course_postships", force: true do |t|
    t.integer  "post_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_simulations", force: true do |t|
    t.integer  "user_id"
    t.integer  "semester_id"
    t.integer  "course_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_simulations", ["course_detail_id"], name: "index_course_simulations_on_course_detail_id", using: :btree
  add_index "course_simulations", ["semester_id"], name: "index_course_simulations_on_semester_id", using: :btree
  add_index "course_simulations", ["user_id"], name: "index_course_simulations_on_user_id", using: :btree

  create_table "course_teacher_page_contents", force: true do |t|
    t.integer  "course_teachership_id"
    t.integer  "exam_record"
    t.integer  "homework_record"
    t.text     "course_note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_user_id"
  end

  create_table "course_teacher_ratings", force: true do |t|
    t.integer "course_teachership_id"
    t.integer "total_rating_counts"
    t.float   "avg_score"
    t.string  "rating_type"
  end

  add_index "course_teacher_ratings", ["course_teachership_id"], name: "index_course_teacher_ratings_on_course_teachership_id", using: :btree

  create_table "course_teacherships", force: true do |t|
    t.integer "course_id"
    t.integer "teacher_id"
  end

  add_index "course_teacherships", ["course_id"], name: "index_course_teacherships_on_course_id", using: :btree
  add_index "course_teacherships", ["teacher_id"], name: "index_course_teacherships_on_teacher_id", using: :btree

  create_table "courses", force: true do |t|
    t.string   "ch_name"
    t.string   "eng_name"
    t.integer  "grade_id"
    t.integer  "department_id"
    t.string   "real_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rate"
  end

  add_index "courses", ["department_id"], name: "index_courses_on_department_id", using: :btree
  add_index "courses", ["grade_id"], name: "index_courses_on_grade_id", using: :btree
  add_index "courses", ["real_id"], name: "index_courses_on_real_id", using: :btree

  create_table "departments", force: true do |t|
    t.string   "ch_name"
    t.string   "eng_name"
    t.string   "real_id"
    t.string   "degree"
    t.integer  "college_id"
    t.string   "dept_type"
    t.integer  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["college_id"], name: "index_departments_on_college_id", using: :btree
  add_index "departments", ["degree"], name: "index_departments_on_degree", using: :btree
  add_index "departments", ["real_id"], name: "index_departments_on_real_id", using: :btree

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

  create_table "each_course_teacher_ratings", force: true do |t|
    t.integer  "course_teacher_rating_id"
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "each_course_teacher_ratings", ["course_teacher_rating_id"], name: "index_each_course_teacher_ratings_on_course_teacher_rating_id", using: :btree
  add_index "each_course_teacher_ratings", ["user_id"], name: "index_each_course_teacher_ratings_on_user_id", using: :btree

  create_table "file_infos", force: true do |t|
    t.integer  "owner_id"
    t.integer  "course_id"
    t.string   "description"
    t.integer  "teacher_id"
    t.integer  "semester_id"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grades", force: true do |t|
    t.string  "name"
    t.integer "degree"
  end

  create_table "posts", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raider_content_lists", force: true do |t|
    t.integer  "course_teacher_page_content_id"
    t.integer  "user_id"
    t.integer  "content_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: true do |t|
    t.integer  "bbs_id"
    t.string   "author"
    t.string   "title"
    t.text     "content",   limit: 2147483647
    t.datetime "date"
    t.integer  "course_id"
  end

  add_index "reviews", ["course_id"], name: "index_reviews_on_course_id", using: :btree

  create_table "semester_courseships", force: true do |t|
    t.integer  "semester_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "semester_courseships", ["course_id"], name: "index_semester_courseships_on_course_id", using: :btree
  add_index "semester_courseships", ["semester_id"], name: "index_semester_courseships_on_semester_id", using: :btree

  create_table "semesters", force: true do |t|
    t.string   "name"
    t.string   "year"
    t.string   "half"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "top_managers", force: true do |t|
    t.integer  "user_id"
    t.integer  "all_users"
    t.integer  "all_departments"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "department_id"
  end

  add_index "users", ["department_id"], name: "index_users_on_department_id", using: :btree

end
