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

ActiveRecord::Schema.define(version: 2022_06_06_213730) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "proposal_id"
    t.bigint "user_id"
    t.integer "parent_id"
    t.text "body"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["proposal_id"], name: "index_comments_on_proposal_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "url"
    t.string "contact_email"
    t.string "state", default: "draft"
    t.boolean "archived", default: false
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "info"
    t.text "guidelines"
    t.text "settings"
    t.text "proposal_tags"
    t.text "review_tags"
    t.text "custom_fields"
    t.text "speaker_notification_emails"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_events_on_slug"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "proposal_id"
    t.bigint "user_id"
    t.string "email"
    t.string "state", default: "pending"
    t.string "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["proposal_id", "email"], name: "index_invitations_on_proposal_id_and_email", unique: true
    t.index ["proposal_id"], name: "index_invitations_on_proposal_id"
    t.index ["slug"], name: "index_invitations_on_slug", unique: true
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.string "message"
    t.string "target_path"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.bigint "website_id"
    t.text "published_body"
    t.text "unpublished_body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "landing", default: false, null: false
    t.boolean "hide_header", default: false, null: false
    t.boolean "hide_footer", default: false, null: false
    t.boolean "hide_page", default: false, null: false
    t.string "footer_category"
    t.datetime "body_published_at"
    t.index ["website_id"], name: "index_pages_on_website_id"
  end

  create_table "program_sessions", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "proposal_id"
    t.text "title"
    t.text "abstract"
    t.bigint "track_id"
    t.bigint "session_format_id"
    t.text "state", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "info"
    t.index ["event_id"], name: "index_program_sessions_on_event_id"
    t.index ["proposal_id"], name: "index_program_sessions_on_proposal_id"
    t.index ["session_format_id"], name: "index_program_sessions_on_session_format_id"
    t.index ["track_id"], name: "index_program_sessions_on_track_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.bigint "event_id"
    t.string "state", default: "submitted"
    t.string "uuid"
    t.string "title"
    t.bigint "session_format_id"
    t.bigint "track_id"
    t.text "abstract"
    t.text "details"
    t.text "pitch"
    t.text "last_change"
    t.text "confirmation_notes"
    t.text "proposal_data"
    t.datetime "updated_by_speaker_at"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_proposals_on_event_id"
    t.index ["session_format_id"], name: "index_proposals_on_session_format_id"
    t.index ["track_id"], name: "index_proposals_on_track_id"
    t.index ["uuid"], name: "index_proposals_on_uuid", unique: true
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "proposal_id"
    t.bigint "user_id"
    t.integer "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["proposal_id"], name: "index_ratings_on_proposal_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name"
    t.string "room_number"
    t.string "level"
    t.string "address"
    t.integer "capacity"
    t.integer "grid_position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_rooms_on_event_id"
  end

  create_table "session_format_configs", force: :cascade do |t|
    t.bigint "website_id"
    t.bigint "session_format_id"
    t.integer "position"
    t.string "name"
    t.boolean "display"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_format_id"], name: "index_session_format_configs_on_session_format_id"
    t.index ["website_id"], name: "index_session_format_configs_on_website_id"
  end

  create_table "session_formats", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name"
    t.string "description"
    t.integer "duration"
    t.boolean "public", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_session_formats_on_event_id"
  end

  create_table "speakers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.bigint "proposal_id"
    t.bigint "program_session_id"
    t.string "speaker_name"
    t.string "speaker_email"
    t.text "bio"
    t.text "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "age_range"
    t.string "ethnicity"
    t.boolean "first_time_speaker"
    t.string "pronouns"
    t.index ["event_id"], name: "index_speakers_on_event_id"
    t.index ["program_session_id"], name: "index_speakers_on_program_session_id"
    t.index ["proposal_id"], name: "index_speakers_on_proposal_id"
    t.index ["user_id"], name: "index_speakers_on_user_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name"
    t.string "tier"
    t.boolean "published"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.string "offer_headline"
    t.text "offer_text"
    t.string "offer_url"
    t.index ["event_id"], name: "index_sponsors_on_event_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "proposal_id"
    t.string "tag"
    t.boolean "internal", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["proposal_id"], name: "index_taggings_on_proposal_id"
  end

  create_table "teammates", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "user_id"
    t.string "role"
    t.string "email"
    t.string "state"
    t.string "token"
    t.datetime "invited_at"
    t.datetime "accepted_at"
    t.datetime "declined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "notification_preference", default: "all"
    t.string "mention_name"
    t.index ["event_id"], name: "index_teammates_on_event_id"
    t.index ["user_id"], name: "index_teammates_on_user_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.bigint "program_session_id"
    t.bigint "room_id"
    t.bigint "event_id"
    t.integer "conference_day"
    t.time "start_time"
    t.time "end_time"
    t.text "title"
    t.text "description"
    t.text "presenter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "track_id"
    t.bigint "sponsor_id"
    t.index ["conference_day"], name: "index_time_slots_on_conference_day"
    t.index ["event_id"], name: "index_time_slots_on_event_id"
    t.index ["program_session_id"], name: "index_time_slots_on_program_session_id"
    t.index ["room_id"], name: "index_time_slots_on_room_id"
    t.index ["sponsor_id"], name: "index_time_slots_on_sponsor_id"
    t.index ["track_id"], name: "index_time_slots_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.bigint "event_id"
    t.string "name"
    t.string "description", limit: 250
    t.text "guidelines"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_tracks_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.text "bio"
    t.boolean "admin", default: false
    t.string "provider"
    t.string "uid"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "website_contents", force: :cascade do |t|
    t.text "html"
    t.string "placement", default: "head", null: false
    t.string "name"
    t.bigint "website_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["website_id"], name: "index_website_contents_on_website_id"
  end

  create_table "website_fonts", force: :cascade do |t|
    t.string "name"
    t.boolean "primary"
    t.boolean "secondary"
    t.bigint "website_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["website_id"], name: "index_website_fonts_on_website_id"
  end

  create_table "website_meta_data", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.text "description"
    t.bigint "website_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["website_id"], name: "index_website_meta_data_on_website_id"
  end

  create_table "websites", force: :cascade do |t|
    t.bigint "event_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "theme", default: "default", null: false
    t.string "domains"
    t.string "city"
    t.text "location"
    t.string "prospectus_link"
    t.string "twitter_handle"
    t.string "directions"
    t.string "footer_categories", default: [], array: true
    t.text "footer_about_content"
    t.string "footer_copyright"
    t.string "facebook_url"
    t.string "instagram_url"
    t.string "navigation_links", default: [], array: true
    t.string "caching", default: "off", null: false
    t.datetime "purged_at"
    t.index ["event_id"], name: "index_websites_on_event_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pages", "websites"
  add_foreign_key "session_format_configs", "session_formats"
  add_foreign_key "session_format_configs", "websites"
  add_foreign_key "session_formats", "events"
  add_foreign_key "sponsors", "events"
  add_foreign_key "website_meta_data", "websites"
  add_foreign_key "websites", "events"
end
