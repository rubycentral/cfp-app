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

  def review
    stats = {'Total' => track_review_stats}
    event.tracks.each do |track|
      stats[track.name] = track_review_stats(track.id)
    end
    stats
  end

  def track_review_stats(track_id='all')
    p = event.proposals
    p = filter_by_track(p, track_id) unless track_id == 'all'
    {
      proposals: p.count,
      reviews: p.rated.count,
      public_comments: PublicComment.joins(:proposal).where(proposal: p).count,
      internal_comments: InternalComment.joins(:proposal).where(proposal: p).count,
      needs_review: p.left_outer_joins(:ratings).group("proposals.id").having("count(ratings.id) < ?", 2).length
    }
  end

  def program
    proposals_per_track_and_state = event.proposals.left_joins(:track).group('tracks.name', :state).count

    stats = {'Total' => {
      accepted: proposals_per_track_and_state.select {|k, _v| k[1] == Proposal::State::ACCEPTED }.sum(&:second) || 0,
      soft_accepted: proposals_per_track_and_state.select {|k, _v| k[1] == Proposal::State::SOFT_ACCEPTED }.sum(&:second) || 0,
      waitlisted: proposals_per_track_and_state.select {|k, _v| k[1] == Proposal::State::WAITLISTED }.sum(&:second) || 0,
      soft_waitlisted: proposals_per_track_and_state.select {|k, _v| k[1] == Proposal::State::SOFT_WAITLISTED }.sum(&:second) || 0
    }}
    # Prepending `nil` for "General" track
    event.tracks.pluck(:name).prepend(nil).each do |track_name|
      stats[track_name || Track::NO_TRACK] = {
        accepted: proposals_per_track_and_state[[track_name, Proposal::State::ACCEPTED]] || 0,
        soft_accepted: proposals_per_track_and_state[[track_name, Proposal::State::SOFT_ACCEPTED]] || 0,
        waitlisted: proposals_per_track_and_state[[track_name, Proposal::State::WAITLISTED]] || 0,
        soft_waitlisted: proposals_per_track_and_state[[track_name, Proposal::State::SOFT_WAITLISTED]] || 0
      }
    end
    stats
  end

  def schedule
    stats = {'Total' => schedule_day_stats}
    event.days.times do |i|
      stats[day_name(i)] = schedule_day_stats(i)
    end
    stats
  end

  def schedule_day_stats(day_index="all")
    days = day_index == "all" ? (1..event.days).to_a : day_index + 1
    time_slots = event.time_slots.where(conference_day: days)
    {
      time_slots: time_slots.size,
      scheduled_slots: time_slots.scheduled.size,
      empty_slots: time_slots.empty.size,
    }
  end

  def day_name(day_index)
    (event.start_date + day_index.days).strftime("%a %b %e")
  end

  def schedule_counts
    time_slots = event.time_slots
    counts = {}
    event.days.times do |day_index|
      day = day_index + 1
      day_slots = time_slots.where(conference_day: day)
      counts[day] = {
        total: day_slots.length,
        scheduled: day_slots.scheduled.length
      }
    end
    counts
  end

  def team
    stats = {}

    comments_per_user_id_and_type = Comment.group(:user_id, :type).joins(:proposal).where(proposals: {event_id: event}).count
    ratings_per_user_id = Rating.group(:user_id).not_withdrawn.for_event(event).count

    event.teammates.active.alphabetize.includes(:user).each do |teammate|
      if (rating_count = ratings_per_user_id[teammate.user_id] || 0) > 0
        stats[teammate.name] = {
          reviews: rating_count,
          public_comments: comments_per_user_id_and_type[[teammate.user_id, 'PublicComment']] || 0,
          internal_comments: comments_per_user_id_and_type[[teammate.user_id, 'InternalComment']] || 0
        }
      end
    end
    stats
  end

  private

  def filter_by_track(q, track_id)
    q = q.in_track(track_id) unless track_id == 'all'
    q
  end
end
