class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :name, :slug
      t.string :url, :contact_email
      t.string :state, default: 'draft'
      t.boolean :archived, default: false
      t.timestamp :opens_at, :closes_at
      t.timestamp :start_date, :end_date
      t.text :info
      t.text :guidelines
      t.text :settings
      t.text :proposal_tags
      t.text :review_tags
      t.text :custom_fields
      t.text :speaker_notification_emails
      t.timestamps null: true
    end

    add_index :events, :slug
  end
end
