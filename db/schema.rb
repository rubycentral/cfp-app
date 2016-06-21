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

ActiveRecord::Schema.define(version: 20160621190447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "comments", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.text     "body"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["proposal_id"], name: "index_comments_on_proposal_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "url"
    t.string   "contact_email"
    t.string   "state",                       default: "closed"
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "proposal_tags"
    t.text     "review_tags"
    t.text     "guidelines"
    t.text     "policies"
    t.boolean  "archived",                    default: false
    t.text     "custom_fields"
    t.hstore   "speaker_notification_emails", default: {"accept"=>"", "reject"=>"", "waitlist"=>""}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["slug"], name: "index_events_on_slug", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.string   "email"
    t.string   "state",       default: "pending"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["proposal_id", "email"], name: "index_invitations_on_proposal_id_and_email", unique: true, using: :btree
  add_index "invitations", ["proposal_id"], name: "index_invitations_on_proposal_id", using: :btree
  add_index "invitations", ["slug"], name: "index_invitations_on_slug", unique: true, using: :btree
  add_index "invitations", ["user_id"], name: "index_invitations_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "message"
    t.datetime "read_at"
    t.string   "target_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "participant_invitations", force: :cascade do |t|
    t.string   "email"
    t.string   "state"
    t.string   "slug"
    t.string   "role"
    t.string   "token"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "role"
    t.boolean  "notifications", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participants", ["event_id"], name: "index_participants_on_event_id", using: :btree
  add_index "participants", ["user_id"], name: "index_participants_on_user_id", using: :btree

  create_table "proposals", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "state",                 default: "submitted"
    t.string   "uuid"
    t.string   "title"
    t.text     "abstract"
    t.text     "details"
    t.text     "pitch"
    t.text     "last_change"
    t.text     "confirmation_notes"
    t.text     "proposal_data"
    t.datetime "updated_by_speaker_at"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "session_type_id"
    t.integer  "track_id"
  end

  add_index "proposals", ["event_id"], name: "index_proposals_on_event_id", using: :btree
  add_index "proposals", ["session_type_id"], name: "index_proposals_on_session_type_id", using: :btree
  add_index "proposals", ["track_id"], name: "index_proposals_on_track_id", using: :btree
  add_index "proposals", ["uuid"], name: "index_proposals_on_uuid", unique: true, using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["proposal_id"], name: "index_ratings_on_proposal_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.string   "name"
    t.string   "room_number"
    t.string   "level"
    t.string   "address"
    t.integer  "capacity"
    t.integer  "grid_position"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rooms", ["event_id"], name: "index_rooms_on_event_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "uname"
    t.string   "account_name"
    t.string   "uemail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree

  create_table "session_types", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "duration"
    t.boolean  "public",      default: true
    t.integer  "event_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "session_types", ["event_id"], name: "index_session_types_on_event_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "conference_day"
    t.time     "start_time"
    t.time     "end_time"
    t.text     "title"
    t.text     "description"
    t.text     "presenter"
    t.integer  "room_id"
    t.integer  "track_id"
    t.integer  "proposal_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["event_id"], name: "index_sessions_on_event_id", using: :btree

  create_table "speakers", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "speakers", ["proposal_id"], name: "index_speakers_on_proposal_id", using: :btree
  add_index "speakers", ["user_id"], name: "index_speakers_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "proposal_id"
    t.string   "tag"
    t.boolean  "internal",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["proposal_id"], name: "index_taggings_on_proposal_id", using: :btree

  create_table "tracks", force: :cascade do |t|
    t.text     "name"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description", limit: 250
    t.text     "guidelines"
  end

  add_index "tracks", ["event_id"], name: "index_tracks_on_event_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                  default: "",    null: false
    t.text     "bio"
    t.boolean  "admin",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "session_types", "events"
end
