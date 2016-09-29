class AddTimeSlotTrack < ActiveRecord::Migration
  def change
    add_reference :time_slots, :track
  end
end
