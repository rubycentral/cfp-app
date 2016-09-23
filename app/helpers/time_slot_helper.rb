module TimeSlotHelper
  def unmet_requirements(event)
    @_unmet_requirements ||= event.unmet_requirements_for_scheduling.map do |msg|
      content_tag :li, msg, class: 'list-group-item custom-list-group-item-danger'
    end.join("\n").html_safe
  end

  def has_missing_requirements?(event)
    @_has_missing_requirements ||= unmet_requirements(event).present?
  end
end
