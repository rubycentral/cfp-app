module TimeSlotHelper
  def unmet_requirements(event)
    @_unmet_requirements ||= event.unmet_requirements_for_scheduling.map do |msg|
      content_tag :li, msg, class: 'list-group-item custom-list-group-item-danger'
    end
    safe_join(@_unmet_requirements, "\n")
  end

  def has_missing_requirements?(event)
    @_has_missing_requirements ||= unmet_requirements(event).present?
  end

  def time_select_options(step_minutes: 5)
    (0..23).flat_map do |hour|
      (0..59).step(step_minutes).map do |minute|
        format('%02d:%02d', hour, minute)
      end
    end
  end
end
