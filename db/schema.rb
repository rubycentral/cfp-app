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

ActiveRecord::Schema[8.1].define(version: 2025_12_19_061613) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil
    t.integer "parent_id"
    t.bigint "proposal_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["proposal_id"], name: "index_comments_on_proposal_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "archived", default: false
    t.datetime "closes_at", precision: nil
    t.string "contact_email"
    t.datetime "created_at", precision: nil
    t.text "custom_fields"
    t.datetime "end_date", precision: nil
    t.text "guidelines"
    t.text "info"
    t.string "name"
    t.datetime "opens_at", precision: nil
    t.text "proposal_tags"
    t.text "review_tags"
    t.text "settings"
    t.string "slug"
    t.text "speaker_notification_emails"
    t.datetime "start_date", precision: nil
    t.string "state", default: "draft"
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.index ["slug"], name: "index_events_on_slug"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "email"
    t.bigint "proposal_id"
    t.string "slug"
    t.string "state", default: "pending"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["proposal_id", "email"], name: "index_invitations_on_proposal_id_and_email", unique: true
    t.index ["proposal_id"], name: "index_invitations_on_proposal_id"
    t.index ["slug"], name: "index_invitations_on_slug", unique: true
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "message"
    t.datetime "read_at", precision: nil
    t.string "target_path"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "body_published_at", precision: nil
    t.datetime "created_at", null: false
    t.string "footer_category"
    t.boolean "hide_footer", default: false, null: false
    t.boolean "hide_header", default: false, null: false
    t.boolean "hide_page", default: false, null: false
    t.boolean "landing", default: false, null: false
    t.string "name", null: false
    t.text "published_body"
    t.string "slug", null: false
    t.text "unpublished_body"
    t.datetime "updated_at", null: false
    t.bigint "website_id"
    t.index ["website_id"], name: "index_pages_on_website_id"
  end

  create_table "program_sessions", force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "event_id"
    t.text "info"
    t.bigint "proposal_id"
    t.bigint "session_format_id"
    t.text "state", default: "draft"
    t.text "title"
    t.bigint "track_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_program_sessions_on_event_id"
    t.index ["proposal_id"], name: "index_program_sessions_on_proposal_id"
    t.index ["session_format_id"], name: "index_program_sessions_on_session_format_id"
    t.index ["track_id"], name: "index_program_sessions_on_track_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.text "abstract"
    t.text "confirmation_notes"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.text "details"
    t.bigint "event_id"
    t.text "last_change"
    t.text "pitch"
    t.text "proposal_data"
    t.bigint "session_format_id"
    t.string "state", default: "submitted"
    t.string "title"
    t.bigint "track_id"
    t.datetime "updated_at", precision: nil
    t.datetime "updated_by_speaker_at", precision: nil
    t.string "uuid"
    t.index ["event_id"], name: "index_proposals_on_event_id"
    t.index ["session_format_id"], name: "index_proposals_on_session_format_id"
    t.index ["track_id"], name: "index_proposals_on_track_id"
    t.index ["uuid"], name: "index_proposals_on_uuid", unique: true
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.bigint "proposal_id"
    t.integer "score"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["proposal_id"], name: "index_ratings_on_proposal_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "address"
    t.integer "capacity"
    t.datetime "created_at", precision: nil
    t.bigint "event_id"
    t.integer "grid_position"
    t.string "level"
    t.string "name"
    t.string "room_number"
    t.datetime "updated_at", precision: nil
    t.index ["event_id"], name: "index_rooms_on_event_id"
  end

  create_table "session_format_configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "display"
    t.string "name"
    t.integer "position"
    t.bigint "session_format_id"
    t.datetime "updated_at", null: false
    t.bigint "website_id"
    t.index ["session_format_id"], name: "index_session_format_configs_on_session_format_id"
    t.index ["website_id"], name: "index_session_format_configs_on_website_id"
  end

  create_table "session_formats", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.integer "duration"
    t.bigint "event_id"
    t.string "name"
    t.boolean "public", default: true
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_session_formats_on_event_id"
  end

  create_table "speakers", force: :cascade do |t|
    t.string "age_range"
    t.text "bio"
    t.datetime "created_at", precision: nil
    t.string "ethnicity"
    t.bigint "event_id"
    t.boolean "first_time_speaker"
    t.text "info"
    t.bigint "program_session_id"
    t.string "pronouns"
    t.bigint "proposal_id"
    t.string "speaker_email"
    t.string "speaker_name"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["event_id"], name: "index_speakers_on_event_id"
    t.index ["program_session_id"], name: "index_speakers_on_program_session_id"
    t.index ["proposal_id"], name: "index_speakers_on_proposal_id"
    t.index ["user_id"], name: "index_speakers_on_user_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "event_id"
    t.string "name"
    t.string "offer_headline"
    t.text "offer_text"
    t.string "offer_url"
    t.boolean "published"
    t.string "tier"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["event_id"], name: "index_sponsors_on_event_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.boolean "internal", default: false
    t.bigint "proposal_id"
    t.string "tag"
    t.datetime "updated_at", precision: nil
    t.index ["proposal_id"], name: "index_taggings_on_proposal_id"
  end

  create_table "teammates", force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "declined_at", precision: nil
    t.string "email"
    t.bigint "event_id"
    t.datetime "invited_at", precision: nil
    t.string "mention_name"
    t.string "notification_preference", default: "all"
    t.string "role"
    t.string "state"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.bigint "user_id"
    t.index ["event_id"], name: "index_teammates_on_event_id"
    t.index ["user_id"], name: "index_teammates_on_user_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "conference_day"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.time "end_time"
    t.bigint "event_id"
    t.text "presenter"
    t.bigint "program_session_id"
    t.bigint "room_id"
    t.bigint "sponsor_id"
    t.time "start_time"
    t.text "title"
    t.bigint "track_id"
    t.datetime "updated_at", precision: nil
    t.index ["conference_day"], name: "index_time_slots_on_conference_day"
    t.index ["event_id"], name: "index_time_slots_on_event_id"
    t.index ["program_session_id"], name: "index_time_slots_on_program_session_id"
    t.index ["room_id"], name: "index_time_slots_on_room_id"
    t.index ["sponsor_id"], name: "index_time_slots_on_sponsor_id"
    t.index ["track_id"], name: "index_time_slots_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "description", limit: 250
    t.bigint "event_id"
    t.text "guidelines"
    t.string "name"
    t.datetime "updated_at", precision: nil
    t.index ["event_id"], name: "index_tracks_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.text "bio"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name"
    t.string "provider"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", precision: nil
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "website_contents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "html"
    t.string "name"
    t.string "placement", default: "head", null: false
    t.datetime "updated_at", null: false
    t.bigint "website_id"
    t.index ["website_id"], name: "index_website_contents_on_website_id"
  end

  create_table "website_fonts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.boolean "primary"
    t.boolean "secondary"
    t.datetime "updated_at", null: false
    t.bigint "website_id"
    t.index ["website_id"], name: "index_website_fonts_on_website_id"
  end

  create_table "website_meta_data", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "website_id"
    t.index ["website_id"], name: "index_website_meta_data_on_website_id"
  end

  create_table "websites", force: :cascade do |t|
    t.string "caching", default: "off", null: false
    t.string "city"
    t.datetime "created_at", null: false
    t.string "directions"
    t.string "domains"
    t.bigint "event_id"
    t.string "facebook_url"
    t.text "footer_about_content"
    t.string "footer_categories", default: [], array: true
    t.string "footer_copyright"
    t.string "instagram_url"
    t.text "location"
    t.string "navigation_links", default: [], array: true
    t.string "prospectus_link"
    t.datetime "purged_at", precision: nil
    t.string "theme", default: "default", null: false
    t.string "twitter_handle"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_websites_on_event_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "identities", "users"
  add_foreign_key "pages", "websites"
  add_foreign_key "session_format_configs", "session_formats"
  add_foreign_key "session_format_configs", "websites"
  add_foreign_key "session_formats", "events"
  add_foreign_key "sponsors", "events"
  add_foreign_key "website_meta_data", "websites"
  add_foreign_key "websites", "events"
end
