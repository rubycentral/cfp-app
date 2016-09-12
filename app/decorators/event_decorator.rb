class EventDecorator < ApplicationDecorator
  delegate_all

  def proposals_rated_overall_message
    overall_rated_count = event.stats.rated_proposals
    total_proposals_count = event.stats.total_proposals
    "#{overall_rated_count}/#{total_proposals_count}"
  end

  def proposals_you_rated_message
    rated_count = event.stats.user_rated_proposals(h.current_user)
    proposals_count = event.stats.user_ratable_proposals(h.current_user)
    "#{rated_count}/#{proposals_count}"
  end

  def path_for(user)
    path = if user && user.organizer_for_event?(object)
      h.event_staff_proposals_path(object)
    else
      h.event_path(object.slug)
    end

    h.link_to h.pluralize(object.proposals.count, 'proposal'), path
  end

  def event_path_for
    if object.url?
      h.link_to object.name, object.url, target: 'blank', class: 'event-title'
    else
      object.name
    end
  end

  def cfp_days_remaining
    ((object.closes_at - DateTime.current).to_i / 1.day) if object.closes_at && (object.closes_at - DateTime.now).to_i / 1.day > 1
  end

  def closes_at(format = nil)
    if format && object.closes_at
      object.closes_at.to_s(format)
    else
      object.closes_at
    end
  end

  def track_count
    Track.count_by_track(object)
  end

  def days_for
    # Add 1 because we include both the start date and end date
    1..((object.end_date.to_date - object.start_date.to_date) + 1)
  end

  def reviewed_percent
    if proposals.count > 1
      "#{((object.proposals.rated.count.to_f/object.proposals.count.to_f)*100).round(1)}%"
    else
      "0%"
    end
  end

  def tweet_button
    twitter_button("Check out the CFP for #{object}!")
  end

  def date_range
    if (object.start_date.month == object.end_date.month) && (event.start_date.day != event.end_date.day)
      object.start_date.strftime("%b %d") + object.end_date.strftime(" \- %d, %Y")
    elsif (object.start_date.month == object.end_date.month) && (event.start_date.day == event.end_date.day)
      object.start_date.strftime("%b %d, %Y")
    else
      object.start_date.strftime("%b %d") + object.end_date.strftime(" \- %b %d, %Y")
    end
  end

  def confirmed_percent
    if proposals.accepted.confirmed.count > 0
      "#{((object.proposals.accepted.confirmed.count.to_f/object.proposals.accepted.count.to_f)*100).round(1)}%"
    else
      "0%"
    end
  end

  def scheduled_count
    tot = object.proposals.accepted.count
    tot - object.program_sessions.unscheduled.count
  end

  def scheduled_percent
    if scheduled_count > 0
      tot = object.proposals.accepted.count.to_f
      sched = tot - object.program_sessions.unscheduled.count.to_f
      "#{((sched/tot)*100).round(1)}%"
    else
      "0%"
    end
  end

  def waitlisted_percent
    if proposals.waitlisted.confirmed.count > 0
      "#{((object.proposals.waitlisted.confirmed.count.to_f/object.proposals.waitlisted.count.to_f)*100).round(1)}%"
    else
      "0%"
    end
  end

  def line_chart
    h.line_chart object.proposals.group_by_day(:created_at, Time.zone, proposal_date_range).count,
      library: {pointSize: 0, lineWidth: 2, series: [{color: '#9ACFEA'}]}
  end

  def conference_day_in_words(day)
    object.conference_date(day).strftime("%A, %B %d - Day #{day}")
  end

  def day
    1
    2
    3
  end

  private

  def proposal_date_range
    now = DateTime.now
    if object.proposals.present? && object.closes_at
      event_first_proposal_created_at =
        object.proposals.order(created_at: :asc).pluck(:created_at).first

      proposal_date_range =
        event_first_proposal_created_at..(now < object.closes_at ? now : object.closes_at )
    else
      proposal_date_range = (now..(now + 3.months))
    end
  end

  def format_date(date)
      date.to_s(:long) if date.present?
  end
end
