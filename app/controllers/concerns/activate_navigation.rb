require "active_support/concern"

module ActivateNavigation
  extend ActiveSupport::Concern

  included do
    helper_method :nav_item_class
    helper_method :program_subnav_item_class
    helper_method :event_subnav_item_class
    helper_method :schedule_subnav_item_class
  end

  def nav_item_class(key)
    return 'active' if matches_nav_path?(key, nav_item_map)
  end

  def event_subnav_item_class(key)
    return 'active' if matches_nav_path?(key, event_subnav_item_map)
  end

  def program_subnav_item_class(key)
    return 'active' if matches_nav_path?(key, program_subnav_item_map)
  end

  def schedule_subnav_item_class(key)
    return 'active' if matches_nav_path?(key, schedule_subnav_item_map)
  end

  private

  def matches_nav_path?(key, paths={})
    if paths.is_a?(String)
      return paths==request.path

    elsif paths.is_a?(Hash)
      return matches_nav_path?(nil, paths.values) if key.nil?
      return paths.any?{|k, p| k==key && matches_nav_path?(nil, p) } # only recurse if the key matches

    elsif paths.is_a?(Array)
      return paths.any?{|p| !p.nil? && matches_nav_path?(nil, p) }
    end
  end

  def nav_item_map
    @nav_item_map ||= {
        'my-proposals-link' => [
            add_path(:proposals),
            add_path(:event_proposal, current_event, @proposal.try(:uuid?) ? @proposal : nil)
        ],
        'event-review-proposals-link' => [
            add_path(:event_staff_proposals, current_event),
            add_path(:event_staff_proposal, current_event, @proposal.try(:uuid?) ? @proposal : nil)
        ],
        'event-program-link' => program_subnav_item_map.values,
        'event-schedule-link' => add_path(:event_staff_schedule_grid, current_event),
        'event-dashboard-link' => event_subnav_item_map.values,
    }
  end

  def event_subnav_item_map
    @event_subnav_item_map ||= {
        'event-staff-dashboard-link' => add_path(:event_staff, current_event),
        'event-staff-info-link' => add_path(:event_staff_info, current_event),
        'event-staff-teammates-link' => add_path(:event_staff_teammates, current_event),
        'event-staff-config-link' => add_path(:event_staff_config, current_event),
        'event-staff-guidelines-link' => add_path(:event_staff_guidelines, current_event),
        'event-staff-speaker-emails-link' => add_path(:event_staff_speaker_email_notifications, current_event),
    }
  end

  def program_subnav_item_map
    @program_subnav_item_map ||= {
        'event-program-proposals-selection-link' => [
            add_path(:selection_event_staff_program_proposals, current_event),
            # add_path(:event_staff_program_proposal, current_event, @proposal)
            #How to leverage session[:prev_page] here? Considering lamdas
        ],
        'event-program-proposals-link' => [
            add_path(:event_staff_program_proposals, current_event),
            add_path(:event_staff_program_proposal, current_event, @proposal.try(:uuid?) ? @proposal : nil)
        ],
        'event-program-sessions-link' => add_path(:event_staff_program_sessions, current_event),
        'event-program-speakers-link' => add_path(:event_staff_program_speakers, current_event),
    }
  end

  def schedule_subnav_item_map
    @schedule_subnav_item_map ||= {
      'event-schedule-time-slots-link' => add_path(:event_staff_schedule_time_slots, current_event),
      'event-schedule-rooms-link' => add_path(:event_staff_schedule_rooms, current_event),
      'event-schedule-grid-link' => add_path(:event_staff_schedule_grid, current_event)
    }
  end

  def add_path(sym, *deps)
    send(sym.to_s + '_path', *deps) unless deps.include?(nil) # don't generate the path unless all dependencies are present
  end
end
