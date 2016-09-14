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

  def accepted_proposals(track='all')
    q = event.proposals.accepted
    q = filter_by_track(q, track)
    q.size
  end

  def waitlisted_proposals(track='all')
    q = event.proposals.waitlisted
    q = filter_by_track(q, track)
    q.size
  end

  def soft_accepted_proposals(track='all')
    q = event.proposals.soft_accepted
    q = filter_by_track(q, track)
    q.size
  end

  def soft_waitlisted_proposals(track='all')
    q = event.proposals.soft_waitlisted
    q = filter_by_track(q, track)
    q.size
  end

  def all_accepted_proposals(track='all')
    q = event.proposals.where(state: [Proposal::ACCEPTED, Proposal::SOFT_ACCEPTED])
    q = filter_by_track(q, track)
    q.size + active_custom_sessions(track)
  end

  def all_waitlisted_proposals(track='all')
    q = event.proposals.where(state: [Proposal::WAITLISTED, Proposal::SOFT_WAITLISTED])
    q = filter_by_track(q, track)
    q.size
  end

  def active_custom_sessions(track='all')
    q = event.program_sessions.active.without_proposal
    q = filter_by_track(q, track)
    q.size
  end

  private

  def filter_by_track(q, track)
    q = q.in_track(track) unless track=='all'
    q
  end
end
