class WebsiteDecorator < ApplicationDecorator
  delegate_all

  def name
    event.name
  end

  def date_range
    event.date_range
  end

  def event
    @event ||= object.event.decorate
  end

  def location
    h.simple_format(object.location)
  end

  def contact_email
    event.contact_email
  end

  def closes_at
    event.closes_at(:month_day_year)
  end
end
