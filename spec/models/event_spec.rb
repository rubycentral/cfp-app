require 'rails_helper'

describe Event do
  describe "live scope" do
    it "returns all open events" do
      live_events =
        create_list(:event, 3, closes_at: 3.weeks.from_now, state: 'open')

      create(:event, closes_at: DateTime.yesterday)
      expect(Event.live).to match_array(live_events)
    end

    it "returns events in ascending cronological order" do
      event1 = create(:event, closes_at: 1.week.from_now, state: 'open')
      event3 = create(:event, closes_at: 3.weeks.from_now, state: 'open')
      event2 = create(:event, closes_at: 2.weeks.from_now, state: 'open')

      expect(Event.live).to eq([ event1, event2, event3 ])
    end
  end

  describe "#open?" do
    it "returns true for open events" do
      event = create(:event, state: 'open', closes_at: 1.week.from_now)
      expect(event).to be_open
    end

    it "returns false for closed events" do
      event = create(:event, state: 'open', closes_at: DateTime.yesterday)
      expect(event).to_not be_open

      event = create(:event, state: nil, closes_at: 3.weeks.from_now)
      expect(event).to_not be_open
    end
  end

  describe "#past_open?" do
    it "returns true for open events past the closing date" do
      event = create(:event, state: 'open', closes_at: 1.week.ago)
      expect(event).to be_past_open
    end

    it "returns false for currently open events" do
      event = create(:event, state: 'open', closes_at: 3.weeks.from_now)
      expect(event).to_not be_past_open
    end

    it "returns false for events that were never open" do
      event = create(:event, state: nil, closes_at: 3.weeks.from_now)
      expect(event).to_not be_past_open
    end
  end

  it 'has a friendly #to_s' do
    event = build :event, name: 'RubyConf 2013'
    expect(event.to_s).to eq 'RubyConf 2013'
  end

  it 'sets its slug on saving' do
    event = build :event, name: 'RubyConf 2013', slug: "", url: 'http://rubyconf.com'
    expect{event.save}.to change{event.slug}.from("").to('rubyconf-2013')
  end

  it 'requires unique slug' do
    first_event = create :event, name: "First"
    second_event = build :event, name: "First"
    expect(first_event).to be_valid
    expect(second_event).to_not be_valid
    expect(second_event.errors[:slug].size).to eq(1)
  end

  describe '#valid_proposal_tags=' do
    let(:event) { build :event }
    it 'splits comma separated string into tags' do
      event.valid_proposal_tags = 'one,two,three'
      event.proposal_tags.should == ['one', 'two', 'three']
    end
  end

  describe '#valid_review_tags=' do
    let(:event) { build :event }
    it 'splits comma separated string into tags' do
      event.valid_review_tags = 'one,two,three'
      event.review_tags.should == ['one', 'two', 'three']
    end
  end

  describe "#unmet_requirements_for_scheduling" do
    it "doesn't show any missing prereqs for valid event" do
      event =
        create(:event, start_date: DateTime.now, end_date: DateTime.tomorrow)
      create(:room, event: event)

      expect(event.unmet_requirements_for_scheduling).to be_empty
    end

    it "shows missing prereqs for invalid event" do
      event = create(:event, start_date: nil, end_date: nil)
      missing = event.unmet_requirements_for_scheduling

      expected_missing = [
        "Event must have a start date",
        "Event must have a end date",
        "Event must have at least one room"
      ]

      expect(missing).to match_array(expected_missing)
    end
  end
end
