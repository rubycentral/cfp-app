class CreateTimeSlots < ActiveRecord::Migration
  def change
    create_table :time_slots do |t|
      t.integer :conference_day
      t.time :start_time
      t.time :end_time
      t.text :title
      t.text :description
      t.text :presenter
      t.references :program_session, index: true
      t.references :room, index: true
      t.references :event, index: true

      t.timestamps
    end
  end
end
