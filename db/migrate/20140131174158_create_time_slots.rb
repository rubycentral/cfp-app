class CreateTimeSlots < ActiveRecord::Migration[5.1]
  def change
    create_table :time_slots do |t|
      t.references :program_session, index: true
      t.references :room, index: true
      t.references :event, index: true
      t.integer :conference_day, index: true
      t.time :start_time
      t.time :end_time
      t.text :title
      t.text :description
      t.text :presenter

      t.timestamps null: true
    end
  end
end
