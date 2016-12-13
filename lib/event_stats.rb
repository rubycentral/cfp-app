class EventStats

  attr_reader :event

  def initialize(event)
    @event = event
  end

  def rated_proposals(include_withdrawn=false)
    q = event.proposals.rated
    q = q.not_withdrawn if include_withdrawn
    q.size
  end

  def total_proposals(include_withdrawn=false)
    q = event.proposals
    q = q.not_withdrawn if include_withdrawn
    q.size
  end

  def user_rated_proposals(user, include_withdrawn=false)
    q = user.ratings.for_event(event)
    q = q.not_withdrawn if include_withdrawn
    q.size
  end

  def user_ratable_proposals(user, include_withdrawn=false)
    q = event.proposals.not_owned_by(user)
    q = q.not_withdrawn if include_withdrawn
    q.size
  end

  def accepted_proposals(track_id='all')
    q = event.proposals.accepted
    q = filter_by_track(q, track_id)
    q.size
  end

  def waitlisted_proposals(track_id='all')
    q = event.proposals.waitlisted
    q = filter_by_track(q, track_id)
    q.size
  end

  def soft_accepted_proposals(track_id='all')
    q = event.proposals.soft_accepted
    q = filter_by_track(q, track_id)
    q.size
  end

  def soft_waitlisted_proposals(track_id='all')
    q = event.proposals.soft_waitlisted
    q = filter_by_track(q, track_id)
    q.size
  end

  def all_accepted_proposals(track_id='all')
    q = event.proposals.where(state: [Proposal::ACCEPTED, Proposal::SOFT_ACCEPTED])
    q = filter_by_track(q, track_id)
    q.size + active_custom_sessions(track_id)
  end

  def all_waitlisted_proposals(track_id='all')
    q = event.proposals.where(state: [Proposal::WAITLISTED, Proposal::SOFT_WAITLISTED])
    q = filter_by_track(q, track_id)
    q.size
  end

  def active_custom_sessions(track_id='all')
    q = event.program_sessions.live.without_proposal
    q = filter_by_track(q, track_id)
    q.size
  end

  def proposals(track_id='all')
    q = event.proposals
    q = filter_by_track(q, track_id)
    q.size
  end

  def ratings(track_id='all')
    q = event.proposals.rated
    q = filter_by_track(q, track_id)
    q.map(&:ratings).flatten.size
  end

  def public_comments(track_id='all')
    q = event.proposals
    q = filter_by_track(q, track_id)
    q.map(&:public_comments).flatten.size
  end

  def internal_comments(track_id='all')
    q = event.proposals
    q = filter_by_track(q, track_id)
    q.map(&:internal_comments).flatten.size
  end

  def user_comments(user)
    q = event.proposals

    public_comments = q.map(&:public_comments).flatten
    internal_comments = q.map(&:internal_comments).flatten

    {
      public: public_comments.select { |c| c.user_id == user.id }.size,
      internal: internal_comments.select { |c| c.user_id == user.id }.size
    }
  end

  def review
    stats = Hash[event.tracks.map do |t|
      [t.name, track_review_stats(t.id)]
    end]

    stats.merge!(no_track_review_stats) if event.closed?
    stats.sort.to_h.merge('Total' => track_review_stats)
  end

  def track_review_stats(track_id='all')
    {
      proposals: proposals(track_id),
      reviews: ratings(track_id),
      public_comments: public_comments(track_id),
      internal_comments: internal_comments(track_id)
    }
  end

  def no_track_review_stats
    { Track::NO_TRACK => track_review_stats('') }
  end

  def program
    stats = Hash[event.tracks.map do |t|
      [t.name, track_program_stats(t.id)]
    end]

    stats.merge!(no_track_program_stats) if event.closed?
    stats.sort.to_h.merge('Total' => track_program_stats)
  end

  def track_program_stats(track_id='all')
    {
      accepted: accepted_proposals(track_id),
      soft_accepted: soft_accepted_proposals(track_id),
      waitlisted: waitlisted_proposals(track_id),
      soft_waitlisted: soft_waitlisted_proposals(track_id)
    }
  end

  def no_track_program_stats
    { Track::NO_TRACK => track_program_stats('') }
  end

  def team
    team = event.teammates.accepted.reject { |t| t.user.ratings.empty? }

    Hash[team.sort_by(&:name).map do |t|
      [t.user.name, teammate_stats(t.user)]
    end]
  end

  def teammate_stats(user)
    comments = user_comments(user)

    {
      reviews: user_rated_proposals(user),
      public_comments: comments[:public],
      internal_comments: comments[:internal]
    }
  end

  private

  def filter_by_track(q, track_id)
    q = q.in_track(track_id) unless track_id == 'all'
    q
  end
end
