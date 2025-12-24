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
    q = event.proposals.where(state: [:accepted, :soft_accepted])
    q = filter_by_track(q, track_id)
    q.size + active_custom_sessions(track_id)
  end

  def all_waitlisted_proposals(track_id='all')
    q = event.proposals.where(state: [:waitlisted, :soft_waitlisted])
    q = filter_by_track(q, track_id)
    q.size
  end

  def active_custom_sessions(track_id='all')
    q = event.program_sessions.live.without_proposal
    q = filter_by_track(q, track_id)
    q.size
  end

  def review
    proposals_per_track = event.proposals.left_joins(:track).group('tracks.name').count
    rated_proposals_per_track = event.proposals.rated.left_joins(:track).group('tracks.name').count
    needs_review_proposals_per_track = event.proposals.left_joins(:ratings, :track).group('tracks.name', 'proposals.id').having('count(ratings.id) < ?', 2).count.group_by {|k, _v| k.first }.transform_values {|v| v.sum(&:second) }
    comments_per_track_and_type = Comment.joins(:proposal).merge(Proposal.left_joins(:track)).group('tracks.name', :type).where(proposals: {event_id: event}).count

    stats = {'Total' => {
      proposals: proposals_per_track.values.sum || 0,
      reviews: rated_proposals_per_track.values.sum || 0,
      needs_review: needs_review_proposals_per_track.values.sum || 0,
      public_comments: comments_per_track_and_type.select {|k, _v| k[1] == 'PublicComment' }.sum(&:second) || 0,
      internal_comments: comments_per_track_and_type.select {|k, _v| k[1] == 'InternalComment' }.sum(&:second) || 0
    }}

    event.tracks.pluck(:name).each do |track_name|
      stats[track_name || Track::NO_TRACK] = {
        proposals: proposals_per_track[track_name] || 0,
        reviews: rated_proposals_per_track[track_name] || 0,
        needs_review: needs_review_proposals_per_track[track_name] || 0,
        public_comments: comments_per_track_and_type[[track_name, 'PublicComment']] || 0,
        internal_comments: comments_per_track_and_type[[track_name, 'InternalComment']] || 0
      }
    end
    stats
  end

  def program
    proposals_per_track_and_state = event.proposals.left_joins(:track).group('tracks.name', :state).count

    stats = {'Total' => {
      accepted: proposals_per_track_and_state.select {|k, _v| k[1] == 'accepted' }.sum(&:second) || 0,
      soft_accepted: proposals_per_track_and_state.select {|k, _v| k[1] == 'soft_accepted' }.sum(&:second) || 0,
      waitlisted: proposals_per_track_and_state.select {|k, _v| k[1] == 'waitlisted' }.sum(&:second) || 0,
      soft_waitlisted: proposals_per_track_and_state.select {|k, _v| k[1] == 'soft_waitlisted' }.sum(&:second) || 0
    }}
    # Prepending `nil` for "General" track
    event.tracks.pluck(:name).prepend(nil).each do |track_name|
      stats[track_name || Track::NO_TRACK] = {
        accepted: proposals_per_track_and_state[[track_name, 'accepted']] || 0,
        soft_accepted: proposals_per_track_and_state[[track_name, 'soft_accepted']] || 0,
        waitlisted: proposals_per_track_and_state[[track_name, 'waitlisted']] || 0,
        soft_waitlisted: proposals_per_track_and_state[[track_name, 'soft_waitlisted']] || 0
      }
    end
    stats
  end

  def schedule
    time_slots_per_day = event.time_slots.group(:conference_day).count
    scheduled_time_slots_per_day = event.time_slots.scheduled.group(:conference_day).count
    empty_time_slots_per_day = event.time_slots.empty.group(:conference_day).count

    stats = {'Total' => {
      time_slots: time_slots_per_day.values.sum || 0,
      scheduled_slots: scheduled_time_slots_per_day.values.sum || 0,
      empty_slots: empty_time_slots_per_day.values.sum || 0
    }}
    event.days.times do |i|
      stats[day_name(i)] = {
        time_slots: time_slots_per_day[i + 1] || 0,
        scheduled_slots: scheduled_time_slots_per_day[i + 1] || 0,
        empty_slots: empty_time_slots_per_day[i + 1] || 0
      }
    end
    stats
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
