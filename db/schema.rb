# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_11_22_174452) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "friend_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "author_id"
    t.index ["name"], name: "index_games_on_name", unique: true
  end

  create_table "games_tags", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_games_tags_on_game_id"
    t.index ["tag_id"], name: "index_games_tags_on_tag_id"
  end

  create_table "jam_submissions", force: :cascade do |t|
    t.integer "jam_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "jams", force: :cascade do |t|
    t.string "name"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "deadline"
    t.date "end_date"
    t.binary "cover"
    t.binary "logo"
    t.string "description"
    t.integer "games", default: [], array: true
    t.integer "participants", default: [], array: true
    t.boolean "users_can_votes", default: false
    t.index ["author_id"], name: "index_jams_on_author_id"
    t.index ["name"], name: "index_jams_on_name"
  end

  create_table "jams_tags", force: :cascade do |t|
    t.bigint "jam_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jam_id"], name: "index_jams_tags_on_jam_id"
    t.index ["tag_id"], name: "index_jams_tags_on_tag_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "actor_id"
    t.string "action"
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "jam_id"
    t.float "average_rating", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_ratings_on_game_id"
    t.index ["jam_id"], name: "index_ratings_on_jam_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.float "user_mark", null: false
    t.string "criterion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.integer "jam_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "session_id"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "browser"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "real_name"
    t.string "birthday"
    t.string "location"
    t.string "phone_number"
    t.string "status"
    t.datetime "last_seen_at"
    t.datetime "last_active_at"
    t.string "remember_token_digest"
    t.string "link_username"
    t.string "timezone"
    t.string "visibility", default: "All"
    t.string "background_image"
    t.string "theme", default: "Light"
    t.string "password_reset_token"
    t.datetime "password_reset_token_sent_at"
    t.string "email_confirm_token"
    t.datetime "email_confirm_token_sent_at"
    t.boolean "email_confirmed", default: false
    t.string "jams_participating_visibility", default: "All"
    t.string "jams_administrating_visibility", default: "All"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "games", "users", column: "author_id"
  add_foreign_key "games_tags", "games"
  add_foreign_key "games_tags", "tags"
  add_foreign_key "jams_tags", "jams"
  add_foreign_key "jams_tags", "tags"
  add_foreign_key "sessions", "users"
end
