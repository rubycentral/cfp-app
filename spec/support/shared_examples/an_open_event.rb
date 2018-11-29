RSpec.shared_examples_for 'an open event' do
  let(:event) { create :event, name: 'Best Event', state: Event::STATUSES[:open] }

  let(:withdrawn) { Proposal::State::WITHDRAWN }
  let(:accepted) { Proposal::State::ACCEPTED }
  let(:soft_accepted) { Proposal::State::SOFT_ACCEPTED }
  let(:waitlisted) { Proposal::State::WAITLISTED }
  let(:soft_waitlisted) { Proposal::State::SOFT_WAITLISTED }

  let(:user1) { create :user, :program_team }
  let(:user2) { create :user, :reviewer }
  let(:no_reviews_user) { create :user }
  let(:invited_user) { create :user }

  let(:teammate1) { create :teammate, :program_team, event: event, user: user1, state: Teammate::ACCEPTED }
  let(:teammate2) { create :teammate, :reviewer, event: event, user: user2, state: Teammate::ACCEPTED }
  let(:no_reviews_teammate) { create :teammate, :reviewer, event: event, user: no_reviews_user, state: Teammate::ACCEPTED }
  let(:invited_teammate) { create :teammate, :has_been_invited, event: event, user: invited_user }

  let(:track1) { create :track, name: 'Open-source', event: event }
  let(:track2) { create :track, name: 'Closed-source', event: event }

  let(:proposal1) { create :proposal, event: event, track: track1, state: accepted }
  let(:proposal2) { create :proposal, event: event, track: track2, state: waitlisted }
  let(:proposal3) { create :proposal, event: event, track: track2, state: soft_accepted }
  let(:no_track_proposal) { create :proposal, event: event, track_id: nil, state: soft_waitlisted }
  let(:withdrawn_proposal) { create :proposal, event: event, track_id: track1, state: withdrawn }

  let!(:rating1) { create :rating, proposal: proposal1, user: user1 }
  let!(:rating2) { create :rating, proposal: proposal2, user: user2 }
  let!(:rating3) { create :rating, proposal: proposal3, user: user1 }
  let!(:rating4) { create :rating, proposal: withdrawn_proposal, user: user2 }

  let!(:comment1) { create :comment, proposal: proposal1, user: user1 }
  let!(:comment2) { create :comment, proposal: proposal1, user: user2 }
  let!(:comment3) { create :comment, :internal, proposal: no_track_proposal, user: user2 }
end
