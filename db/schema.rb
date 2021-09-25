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

ActiveRecord::Schema.define(version: 2021_09_23_090408) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "org_event_logs", force: :cascade do |t|
    t.integer "organisation_id"
    t.string "title"
    t.text "description"
    t.string "attachment"
    t.text "data"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "task_id"
    t.integer "organisation_task_id"
  end

  create_table "organisation_tasks", force: :cascade do |t|
    t.integer "organisation_id"
    t.integer "task_id"
    t.date "start_at"
    t.date "end_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.string "phone_no"
    t.string "email"
    t.text "help_desk_info"
    t.string "customer_contact"
    t.text "additional_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.integer "created_by_id"
    t.string "os"
    t.string "cpu"
    t.string "ram"
    t.string "disk"
    t.string "logical_processors"
    t.string "cores"
    t.string "stack_name"
    t.string "topology"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "task_type"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_organisations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
  end

  create_table "user_role_infos", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "is_admin", default: false
    t.boolean "is_consultant", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname"
    t.string "lastname"
    t.string "phone_no"
    t.string "authentication_token", limit: 30
    t.integer "created_by_id"
    t.boolean "blocked", default: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
