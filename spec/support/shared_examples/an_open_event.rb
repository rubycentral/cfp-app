RSpec.shared_examples_for 'an open event' do
  let(:event) { create :event, name: 'Best Event', state: :open }

  let(:withdrawn) { :withdrawn }
  let(:accepted) { :accepted }
  let(:soft_accepted) { :soft_accepted }
  let(:waitlisted) { :waitlisted }
  let(:soft_waitlisted) { :soft_waitlisted }

  let(:user1) { create :user, :program_team }
  let(:user2) { create :user, :reviewer }
  let(:no_reviews_user) { create :user }
  let(:invited_user) { create :user }

  let(:teammate1) { create :teammate, :program_team, event: event, user: user1, state: :accepted }
  let(:teammate2) { create :teammate, :reviewer, event: event, user: user2, state: :accepted }
  let(:no_reviews_teammate) { create :teammate, :reviewer, event: event, user: no_reviews_user, state: :accepted }
  let(:invited_teammate) { create :teammate, :has_been_invited, event: event, user: invited_user }

  let(:track1) { create :track, name: 'Open-source', event: event }
  let(:track2) { create :track, name: 'Closed-source', event: event }

  let(:proposal1) { create :proposal_with_track, event: event, track: track1, state: accepted }
  let(:proposal2) { create :proposal_with_track, event: event, track: track2, state: waitlisted }
  let(:proposal3) { create :proposal_with_track, event: event, track: track2, state: soft_accepted }
  let(:no_track_proposal) { create :proposal, event: event, track: nil, state: soft_waitlisted }
  let(:withdrawn_proposal) { create :proposal, event: event, track: track1, state: withdrawn }

  let!(:rating1) { create :rating, proposal: proposal1, user: user1 }
  let!(:rating2) { create :rating, proposal: proposal2, user: user2 }
  let!(:rating3) { create :rating, proposal: proposal3, user: user1 }
  let!(:rating4) { create :rating, proposal: withdrawn_proposal, user: user2 }

  let!(:comment1) { create :comment, proposal: proposal1, user: user1 }
  let!(:comment2) { create :comment, proposal: proposal1, user: user2 }
  let!(:comment3) { create :comment, :internal, proposal: no_track_proposal, user: user2 }
end
