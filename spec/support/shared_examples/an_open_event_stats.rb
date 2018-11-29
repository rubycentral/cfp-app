RSpec.shared_examples_for 'an open event stats' do
  include_examples 'an open event'

  ### Review Stats
  let(:track1_review_stats) do
    {
      proposals: track1.proposals.count,
      reviews: track1.proposals.map(&:ratings).flatten.count,
      public_comments: track1.proposals.map(&:public_comments).flatten.count,
      internal_comments: track1.proposals.map(&:internal_comments).flatten.count,
      needs_review: track1.proposals.left_outer_joins(:ratings).group("proposals.id").having("count(ratings.id) < ?", 2).length
    }
  end
  let(:track2_review_stats) do
    {
      proposals: track2.proposals.count,
      reviews: track2.proposals.map(&:ratings).flatten.count,
      public_comments: track2.proposals.map(&:public_comments).flatten.count,
      internal_comments: track2.proposals.map(&:internal_comments).flatten.count,
      needs_review: track2.proposals.left_outer_joins(:ratings).group("proposals.id").having("count(ratings.id) < ?", 2).length
    }
  end
  let(:no_track_review_stats) do
    props = event.proposals.where(track: nil)
    {
      proposals: props.count,
      reviews: props.map(&:ratings).flatten.count,
      public_comments: props.map(&:public_comments).flatten.count,
      internal_comments: props.map(&:internal_comments).flatten.count,
      needs_review: props.left_outer_joins(:ratings).group("proposals.id").having("count(ratings.id) < ?", 2).length

    }
  end
  let(:total_proposals) do
    track1_review_stats[:proposals] +
    track2_review_stats[:proposals] +
    no_track_review_stats[:proposals]
  end
  let(:total_reviews) do
    track1_review_stats[:reviews] +
    track2_review_stats[:reviews] +
    no_track_review_stats[:reviews]
  end
  let(:total_public_comments) do
    track1_review_stats[:public_comments] +
    track2_review_stats[:public_comments] +
    no_track_review_stats[:public_comments]
  end
  let(:total_internal_comments) do
    track1_review_stats[:internal_comments] +
    track2_review_stats[:internal_comments] +
    no_track_review_stats[:internal_comments]
  end
  let(:total_needs_review) do
    track1_review_stats[:needs_review] +
    track2_review_stats[:needs_review] +
    no_track_review_stats[:needs_review]
  end
  let(:total_review_stats) do
    {
      proposals: total_proposals,
      reviews: total_reviews,
      public_comments: total_public_comments,
      internal_comments: total_internal_comments,
      needs_review: total_needs_review
    }
  end
  let(:review_stats) do
    {
      track1.name => track1_review_stats,
      track2.name => track2_review_stats,
      'Total' => total_review_stats
    }
  end

  ### Program Stats
  let(:track1_program_stats) do
    props = Proposal.where(track: track1)

    {
      accepted: props.where(state: accepted).count,
      soft_accepted: props.where(state: soft_accepted).count,
      waitlisted: props.where(state: waitlisted).count,
      soft_waitlisted: props.where(state: soft_waitlisted).count
    }
  end
  let(:track2_program_stats) do
    props = Proposal.where(track: track2)

    {
      accepted: props.where(state: accepted).count,
      soft_accepted: props.where(state: soft_accepted).count,
      waitlisted: props.where(state: waitlisted).count,
      soft_waitlisted: props.where(state: soft_waitlisted).count
    }
  end
  let(:no_track_program_stats) do
    props = event.proposals.where(track: nil)

    {
      accepted: props.where(state: accepted).count,
      soft_accepted: props.where(state: soft_accepted).count,
      waitlisted: props.where(state: waitlisted).count,
      soft_waitlisted: props.where(state: soft_waitlisted).count
    }
  end
  let(:total_accepted) do
    track1_program_stats[:accepted] +
    track2_program_stats[:accepted] +
    no_track_program_stats[:accepted]
  end
  let(:total_soft_accepted) do
    track1_program_stats[:soft_accepted] +
    track2_program_stats[:soft_accepted] +
    no_track_program_stats[:soft_accepted]
  end
  let(:total_waitlisted) do
    track1_program_stats[:waitlisted] +
    track2_program_stats[:waitlisted] +
    no_track_program_stats[:waitlisted]
  end
  let(:total_soft_waitlisted) do
    track1_program_stats[:soft_waitlisted] +
    track2_program_stats[:soft_waitlisted] +
    no_track_program_stats[:soft_waitlisted]
  end
  let(:total_program_stats) do
    {
      accepted: total_accepted,
      soft_accepted: total_soft_accepted,
      waitlisted: total_waitlisted,
      soft_waitlisted: total_soft_waitlisted
    }
  end
  let(:program_stats) do
    {
      track1.name => track1_program_stats,
      track2.name => track2_program_stats,
      'Total' => total_program_stats,
      Track::NO_TRACK => no_track_program_stats
    }
  end

  ### Team Stats
  let(:teammate1_stats) do
    {
      reviews: user1.ratings.not_withdrawn.for_event(event).count,
      public_comments: user1.comments.where(type: 'PublicComment').count,
      internal_comments: user1.comments.where(type: 'InternalComment').count
    }
  end
  let(:teammate2_stats) do
    {
      reviews: user2.ratings.not_withdrawn.for_event(event).count,
      public_comments: user2.comments.where(type: 'PublicComment').count,
      internal_comments: user2.comments.where(type: 'InternalComment').count
    }
  end
  let(:team_stats) do
    {
      user1.name => teammate1_stats,
      user2.name => teammate2_stats
    }
  end
end
