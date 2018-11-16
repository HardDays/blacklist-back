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

ActiveRecord::Schema.define(version: 2018_11_16_215202) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ban_list_comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "ban_list_id"
    t.integer "comment_type"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ban_lists", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "addresses"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 1
    t.string "text"
    t.integer "item_type", default: 1
  end

  create_table "companies", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "description"
    t.string "contacts"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "comment_type"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_offers", force: :cascade do |t|
    t.integer "employee_id"
    t.string "position"
    t.string "description"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "second_name"
    t.datetime "birthday"
    t.integer "gender"
    t.string "education"
    t.string "education_year"
    t.string "contacts"
    t.string "skills"
    t.integer "experience"
    t.integer "status", default: 0
    t.integer "user_id"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forgot_password_attempts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "attempt_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string "base64"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name"
    t.string "period"
    t.string "position"
    t.string "description"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens", force: :cascade do |t|
    t.integer "user_id"
    t.string "info"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "password"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "image_id"
    t.boolean "is_payed", default: false
    t.boolean "is_admin", default: false
    t.boolean "is_blocked", default: false
  end

  create_table "vacancies", force: :cascade do |t|
    t.string "description"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
    t.integer "min_experience"
    t.integer "salary"
  end

  create_table "vacancy_responses", force: :cascade do |t|
    t.integer "vacancy_id"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
