class CreateEvents < ActiveRecord::Migration
  def change
    enable_extension "hstore"

    create_table :events do |t|
      t.string :name, :slug
      t.string :url, :contact_email
      t.string :state, default: "closed"
      t.timestamp :opens_at, :closes_at
      t.timestamp :start_date, :end_date
      t.text :proposal_tags, :review_tags
      t.text :guidelines, :policies
      t.hstore :speaker_notification_emails, default: { accept: "",
                                                        reject: "",
                                                        waitlist: "" }
      t.timestamps
    end

    add_index :events, :slug
  end
end
