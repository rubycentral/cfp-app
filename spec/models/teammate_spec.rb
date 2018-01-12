require 'rails_helper'

describe Teammate do

  describe "validations" do
    it "requires names and emails to be unique per event" do
      teammate1 = create(:teammate, role: "reviewer", email: 'teammate@event.com', mention_name: 'teammate')
      teammate2 = build(:teammate, role: "reviewer", email: teammate1.email, mention_name: teammate1.mention_name)

      expect(teammate2).to be_invalid
      expect(teammate2.errors.messages.keys).to include(:email, :mention_name)
    end
  end

  describe "#ratings_count" do
    let(:green_event) { create(:event, name: "Green or Greener Event") }
    let(:apple_event) { create(:event, name: "Most Apple Event") }

    let(:dark_green_proposal) { create(:proposal, event: green_event) }
    let(:light_green_proposal) { create(:proposal, event: green_event) }
    let(:jack_proposal) { create(:proposal, event: apple_event) }
    let(:withdrawn_proposal) { create(:proposal, event: green_event, state: "withdrawn") }

    let(:guy_user) { create(:user) }
    let(:gal_user) { create(:user) }

    let(:green_guy_reviewer) { create(:teammate, event: green_event, user: guy_user, role: "reviewer") }
    let(:apple_guy_reviewer) { create(:teammate, event: apple_event, user: guy_user, role: "reviewer") }
    let(:green_gal_reviewer) { create(:teammate, event: green_event, user: gal_user, role: "reviewer") }

    let!(:rating_1) { create(:rating, proposal: dark_green_proposal, user: guy_user) }
    let!(:rating_2) { create(:rating, proposal: light_green_proposal, user: guy_user) }

    it "returns the teammate's rated proposal count for the given event" do
      expect(green_guy_reviewer.ratings_count(green_event)).to eq(2)
      expect(green_gal_reviewer.ratings_count(green_event)).to eq(0)

      create(:rating, proposal: jack_proposal, user: guy_user)
      create(:rating, proposal: light_green_proposal, user: gal_user)

      expect(green_guy_reviewer.ratings_count(green_event)).to eq(2)
      expect(green_guy_reviewer.ratings_count(apple_event)).to eq(1)
      expect(green_gal_reviewer.ratings_count(green_event)).to eq(1)

      create(:rating, proposal: withdrawn_proposal, user: gal_user)

      expect(green_gal_reviewer.ratings_count(green_event)).to eq(1)
      expect(green_gal_reviewer.ratings_count(apple_event)).to eq(0)

      #total ratings overall, not scoped to event or status for comparison check
      expect(guy_user.ratings.count).to eq(3)
      expect(gal_user.ratings.count).to eq(2)
    end
  end
end
