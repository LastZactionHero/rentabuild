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

ActiveRecord::Schema.define(version: 20150525013233) do

  create_table "landing_page_signups", force: true do |t|
    t.string   "email"
    t.string   "zipcode"
    t.string   "model_name"
    t.string   "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",         precision: 6, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_plan_id"
  end

  create_table "promo_codes", force: true do |t|
    t.string   "code"
    t.string   "description"
    t.float    "amount_off"
    t.boolean  "free_shipping"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rentals", force: true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.string   "shipping"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "unit"
    t.string   "zipcode"
    t.string   "stripe_card_token"
    t.string   "stripe_charge_id"
    t.decimal  "amount"
    t.integer  "promo_code_id"
    t.integer  "printer_id",        default: 0
  end

  create_table "user_plans", force: true do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.string   "stripe_subscription_id"
    t.string   "stripe_customer_id"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_plans", ["plan_id"], name: "index_user_plans_on_plan_id"
  add_index "user_plans", ["user_id"], name: "index_user_plans_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                       default: ""
    t.string   "encrypted_password",          default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin",                       default: false
    t.string   "username"
    t.string   "twitter_access_token"
    t.string   "twitter_access_token_secret"
  end

  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["provider"], name: "index_users_on_provider"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["uid"], name: "index_users_on_uid"

end
