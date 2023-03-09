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

ActiveRecord::Schema[7.0].define(version: 202211111668232192) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "boxoffice_headers", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "header_row"
    t.integer "first_name"
    t.integer "last_name"
    t.integer "email"
    t.integer "seat_section"
    t.integer "tickets"
    t.index ["event_id"], name: "index_boxoffice_headers_on_event_id"
  end

  create_table "boxoffice_seats", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "seat_section"
    t.integer "booked_count"
    t.index ["event_id"], name: "index_boxoffice_seats_on_event_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "subject"
    t.string "body"
    t.boolean "is_html", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_email_templates_on_event_id"
    t.index ["user_id"], name: "index_email_templates_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "address", null: false
    t.datetime "datetime", precision: nil, null: false
    t.string "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "guest_referral_rewards", force: :cascade do |t|
    t.integer "guest_id", null: false
    t.integer "referral_reward_id", null: false
    t.integer "count", default: 0
    t.index ["guest_id"], name: "index_guest_referral_rewards_on_guest_id"
    t.index ["referral_reward_id"], name: "index_guest_referral_rewards_on_referral_reward_id"
  end

  create_table "guest_referrals", force: :cascade do |t|
    t.integer "guest_id", null: false
    t.string "email", null: false
    t.boolean "counted", default: false, null: false
    t.index ["email"], name: "index_guest_referrals_on_email"
    t.index ["guest_id"], name: "index_guest_referrals_on_guest_id"
  end

  create_table "guest_seat_tickets", force: :cascade do |t|
    t.integer "guest_id", null: false
    t.integer "seat_id", null: false
    t.integer "committed"
    t.integer "allotted", default: 0
    t.index ["guest_id", "seat_id"], name: "index_guest_seat_tickets_on_guest_id_and_seat_id", unique: true
    t.index ["guest_id"], name: "index_guest_seat_tickets_on_guest_id"
    t.index ["seat_id"], name: "index_guest_seat_tickets_on_seat_id"
  end

  create_table "guests", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "added_by", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "affiliation"
    t.string "type"
    t.boolean "booked"
    t.datetime "invite_expiration", precision: nil
    t.datetime "referral_expiration", precision: nil
    t.datetime "invited_at", precision: nil
    t.datetime "emailed_at", precision: nil
    t.boolean "checked", default: false
    t.integer "guestcommitted"
    t.string "perks"
    t.string "comments"
    t.index ["added_by"], name: "index_guests_on_added_by"
    t.index ["email", "event_id"], name: "index_guests_on_email_and_event_id", unique: true
    t.index ["event_id"], name: "index_guests_on_event_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "referral_rewards", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "reward"
    t.integer "min_count", default: 0
    t.index ["event_id"], name: "index_referral_rewards_on_event_id"
  end

  create_table "sale_tickets", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "seat_section"
    t.integer "tickets"
    t.index ["event_id"], name: "index_sale_tickets_on_event_id"
    t.index ["user_id"], name: "index_sale_tickets_on_user_id"
  end

  create_table "seat_category_details", force: :cascade do |t|
    t.string "event_title"
    t.string "seat_category"
    t.integer "total_seats"
    t.integer "vip_seats"
    t.integer "non_vip_seats"
    t.integer "balance"
  end

  create_table "seats", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "category", null: false
    t.integer "total_count"
    t.float "price"
    t.index ["event_id"], name: "index_seats_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "deactivated", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "boxoffice_headers", "events"
  add_foreign_key "boxoffice_seats", "events"
  add_foreign_key "email_templates", "events"
  add_foreign_key "email_templates", "users"
  add_foreign_key "events", "users"
  add_foreign_key "guest_referral_rewards", "guests"
  add_foreign_key "guest_referral_rewards", "referral_rewards"
  add_foreign_key "guest_referrals", "guests"
  add_foreign_key "guest_seat_tickets", "guests"
  add_foreign_key "guest_seat_tickets", "seats"
  add_foreign_key "guests", "events"
  add_foreign_key "guests", "users", column: "added_by"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "referral_rewards", "events"
  add_foreign_key "sale_tickets", "events"
  add_foreign_key "sale_tickets", "users"
  add_foreign_key "seats", "events"
end
