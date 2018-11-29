require 'rails_helper'

RSpec.describe EventStats do
  include_examples 'an open event stats'

  before do
    no_reviews_teammate
    invited_teammate
    withdrawn_proposal
  end

  subject { EventStats.new(event) }

  describe '#review_stats' do
    it 'returns the expected review stats hash' do
      expect(subject.review).to eq review_stats
    end
  end

  describe '#program_stats' do
    it 'returns the expected program stats hash' do
      expect(subject.program).to eq program_stats
    end
  end

  describe '#team_stats' do
    before do
      teammate1
      teammate2
    end

    it 'returns the expected team stats hash' do
      expect(subject.team).to eq team_stats
    end
  end

  context 'closed event' do
    before { event.update(state: Event::STATUSES[:closed]) }

    it 'includes no track stats' do
      expect(subject.program).to have_key Track::NO_TRACK
    end
  end
end
