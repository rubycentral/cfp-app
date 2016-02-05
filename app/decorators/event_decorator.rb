class EventDecorator < ApplicationDecorator
  delegate_all

  def proposals_rated_message
    rated_count = h.current_user.ratings.for_event(object).size
    proposals_count = object.proposals.not_withdrawn.size

    message = "#{rated_count}/#{proposals_count}"

    if rated_count == proposals_count
      message += " (\/)!_!(\/) You rated everything? Nice work! (\/)!_!(\/)"
    end

    message
  end

  def path_for(person)
    path = if person && person.organizer_for_event?(object)
      h.organizer_event_proposals_path(object)
    else
      h.event_path(object.slug)
    end

    h.link_to h.pluralize(object.proposals.count, 'proposal'), path
  end

  def cfp_days_remaining
    ((object.closes_at - DateTime.now).to_i / 1.day) if object.closes_at && (object.closes_at - DateTime.now).to_i / 1.day > 1
  end

  def closes_at(format = nil)
    if format
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

  def confirmed_percent
    if proposals.accepted.confirmed.count > 0
      "#{((object.proposals.accepted.confirmed.count.to_f/object.proposals.accepted.count.to_f)*100).round(1)}%"
    else
      "0%"
    end
  end

  def scheduled_percent
    if proposals.scheduled.count > 0
      "#{((object.proposals.scheduled.count.to_f/object.proposals.accepted.count.to_f)*100).round(1)}%"
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
