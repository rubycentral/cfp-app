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

ActiveRecord::Schema.define(version: 20150512191412) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "comments", force: true do |t|
    t.integer  "proposal_id"
    t.integer  "person_id"
    t.integer  "parent_id"
    t.text     "body"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["person_id"], name: "index_comments_on_person_id", using: :btree
  add_index "comments", ["proposal_id"], name: "index_comments_on_proposal_id", using: :btree

  create_table "events", force: true do |t|
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
    t.hstore   "speaker_notification_emails", default: {"accept"=>"", "reject"=>"", "waitlist"=>""}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",                    default: false
  end

  add_index "events", ["slug"], name: "index_events_on_slug", using: :btree

  create_table "invitations", force: true do |t|
    t.integer  "proposal_id"
    t.integer  "person_id"
    t.string   "email"
    t.string   "state",       default: "pending"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["person_id"], name: "index_invitations_on_person_id", using: :btree
  add_index "invitations", ["proposal_id", "email"], name: "index_invitations_on_proposal_id_and_email", unique: true, using: :btree
  add_index "invitations", ["proposal_id"], name: "index_invitations_on_proposal_id", using: :btree
  add_index "invitations", ["slug"], name: "index_invitations_on_slug", unique: true, using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.datetime "read_at"
    t.string   "target_path"
  end

  add_index "notifications", ["person_id"], name: "index_notifications_on_person_id", using: :btree

  create_table "participant_invitations", force: true do |t|
    t.string   "email"
    t.string   "state"
    t.string   "slug"
    t.string   "role"
    t.string   "token"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", force: true do |t|
    t.integer  "event_id"
    t.integer  "person_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notifications", default: true
  end

  add_index "participants", ["event_id"], name: "index_participants_on_event_id", using: :btree
  add_index "participants", ["person_id"], name: "index_participants_on_person_id", using: :btree

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "bio"
    t.hstore   "demographics"
    t.boolean  "admin",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proposals", force: true do |t|
    t.integer  "event_id"
    t.string   "state",                 default: "submitted"
    t.string   "uuid"
    t.string   "title"
    t.text     "abstract"
    t.text     "details"
    t.text     "pitch"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "last_change"
    t.text     "confirmation_notes"
    t.datetime "updated_by_speaker_at"
    t.text     "proposal_data"
  end

  add_index "proposals", ["event_id"], name: "index_proposals_on_event_id", using: :btree
  add_index "proposals", ["uuid"], name: "index_proposals_on_uuid", unique: true, using: :btree

  create_table "ratings", force: true do |t|
    t.integer  "proposal_id"
    t.integer  "person_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["person_id"], name: "index_ratings_on_person_id", using: :btree
  add_index "ratings", ["proposal_id"], name: "index_ratings_on_proposal_id", using: :btree

  create_table "rooms", force: true do |t|
    t.string   "name"
    t.string   "room_number"
    t.string   "level"
    t.string   "address"
    t.integer  "capacity"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grid_position"
  end

  add_index "rooms", ["event_id"], name: "index_rooms_on_event_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "person_id"
    t.string   "uname"
    t.string   "uemail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["person_id"], name: "index_services_on_person_id", using: :btree

  create_table "sessions", force: true do |t|
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

  create_table "speakers", force: true do |t|
    t.integer  "proposal_id"
    t.integer  "person_id"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "speakers", ["person_id"], name: "index_speakers_on_person_id", using: :btree
  add_index "speakers", ["proposal_id"], name: "index_speakers_on_proposal_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "proposal_id"
    t.string   "tag"
    t.boolean  "internal",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["proposal_id"], name: "index_taggings_on_proposal_id", using: :btree

  create_table "tracks", force: true do |t|
    t.text     "name"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["event_id"], name: "index_tracks_on_event_id", using: :btree

end
