require 'rails_helper'

describe Track do
  describe "validations" do
    it "requires names are unique" do
      track = create(:track, name: 'name')
      track2 = build(:track, name: track.name)

      expect(track2).to be_invalid
    end

    it "requires that name is present" do
      track = build(:track, name: nil)
      expect(track).to be_invalid

      track.name = ''
      expect(track).to be_invalid

      track.name = 'name'
      expect(track).to be_valid
    end
  end
end
