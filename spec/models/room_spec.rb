require 'rails_helper'

describe Room do
  describe "validations" do
    it "requires that names are unique" do
      room = create(:room, name: 'name')
      room2 = build(:room, name: room.name)

      expect(room2).to be_invalid
    end
  end
end
