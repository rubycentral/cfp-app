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

ActiveRecord::Schema.define(version: 20180111175100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["event_id"], name: "index_speakers_on_event_id"
    t.index ["program_session_id"], name: "index_speakers_on_program_session_id"
    t.index ["proposal_id"], name: "index_speakers_on_proposal_id"
    t.index ["user_id"], name: "index_speakers_on_user_id"
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
    t.index ["conference_day"], name: "index_time_slots_on_conference_day"
    t.index ["event_id"], name: "index_time_slots_on_event_id"
    t.index ["program_session_id"], name: "index_time_slots_on_program_session_id"
    t.index ["room_id"], name: "index_time_slots_on_room_id"
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

  add_foreign_key "session_formats", "events"
end
