class AddSponsorToTimeSlots < ActiveRecord::Migration[6.1]
  def change
    add_reference :time_slots, :sponsor
  end
end
