class AddTimeSlotTrack < ActiveRecord::Migration[5.1]
  def change
    add_reference :time_slots, :track
  end
end
