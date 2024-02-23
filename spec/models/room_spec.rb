require 'rails_helper'

describe Room do
  describe "validations" do
    it "requires that names are unique within an event" do
      event1 = create(:event)
      room = create(:room, event: event1, name: 'name')
      room2 = build(:room, event: event1, name: room.name)
      expect(room2).to be_invalid

      event2 = create(:event)
      room3 = build(:room, event: event2, name: room.name)
      expect(room3).to be_valid
    end
  end
end
