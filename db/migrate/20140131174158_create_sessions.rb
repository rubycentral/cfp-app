class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :conference_day
      t.datetime :start_time
      t.datetime :end_time
      t.text :title
      t.text :description
      t.text :presenter
      t.belongs_to :room
      t.belongs_to :track
      t.belongs_to :proposal
      t.references :event, index: true

      t.timestamps
    end
  end
end
