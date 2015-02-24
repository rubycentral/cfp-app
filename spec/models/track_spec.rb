require 'rails_helper'

describe Track do
  describe "validations" do
    it "requires names are unique" do
      track = create(:track, name: 'name')
      track2 = build(:track, name: track.name)

      expect(track2).to be_invalid
    end

    it "allows a duplicate name from another event" do
      old_event = create(:event, name: "Old")
      new_event = create(:event, name: "New")

      original_track = old_event.tracks.create(name: "Dup")
      expect(original_track).to be_valid

      dup_track = new_event.tracks.build(name: "Dup")
      expect(dup_track).to be_valid
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
