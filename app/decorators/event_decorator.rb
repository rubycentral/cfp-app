class EventDecorator < Draper::Decorator
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

  def closes_at(format = nil)
    if format && object.closes_at
      object.closes_at.to_fs(format)
    else
      object.closes_at
    end
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

  def line_chart
    h.line_chart object.proposals.group_by_day(:created_at, range: proposal_date_range).count,
      colors: ['#9ACFEA'], library: {elements: {point: {radius: 0}, line: {borderWidth: 2}}}
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
    now = Time.current

    if object.closes_at && (event_first_proposal_created_at = object.proposals.order(created_at: :asc).pick(:created_at))
      event_first_proposal_created_at..(now < object.closes_at ? now : object.closes_at )
    else
      (now..(now + 3.months))
    end
  end
end
