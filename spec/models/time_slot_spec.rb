require 'rails_helper'

describe TimeSlot do
  describe 'validations' do
    it 'ensures unique start time for room and day' do
      original = create(:time_slot)
      duplicate = build(:time_slot, room: original.room)
      expect(duplicate).to_not be_valid

      duplicate.conference_day += 1
      expect(duplicate).to be_valid
    end
  end
end
