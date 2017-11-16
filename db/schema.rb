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

ActiveRecord::Schema.define(version: 20171115122458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendships", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "user_blocks", force: :cascade do |t|
    t.integer "requestor_id"
    t.integer "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requestor_id"], name: "index_user_blocks_on_requestor_id"
    t.index ["target_id"], name: "index_user_blocks_on_target_id"
  end

  create_table "user_relationships", force: :cascade do |t|
    t.integer "user_one_id"
    t.integer "user_two_id"
    t.boolean "is_blocked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_one_id"], name: "index_user_relationships_on_user_one_id"
    t.index ["user_two_id"], name: "index_user_relationships_on_user_two_id"
  end

  create_table "user_subscribes", force: :cascade do |t|
    t.integer "subscriber_id"
    t.integer "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_user_subscribes_on_publisher_id"
    t.index ["subscriber_id"], name: "index_user_subscribes_on_subscriber_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "friendships", "users"
end
