require "active_support/concern"

module ActivateNavigation
  extend ActiveSupport::Concern

  included do
    helper_method :nav_item_class
    helper_method :subnav_item_class
  end

  def nav_item_class(key)
    initialize_nav
    return 'active' if @active_nav_key == key
  end

  def subnav_item_class(key)
    initialize_nav
    return 'active' if @active_subnav_key == key
  end

  private

  def initialize_nav
    return if @active_nav_key || @active_subnav_key

    @active_nav_key, subnav_map = find_first(nav_item_map)
    @active_subnav_key, nop = find_first(subnav_map)
  end

  def find_first(item_map)
    return unless item_map.is_a?(Hash)

    item_map.find do |key, paths|
      match?(paths)
    end
  end

  def match?(paths)
    if paths.is_a?(String)
      paths == request.path

    elsif paths.is_a?(Regexp)
      paths =~ request.path

    elsif paths.is_a?(Array)
      paths.any?{|p| match?(p) }

    elsif paths.is_a?(Hash)
      find_first(paths).present?
    end
  end

  def nav_item_map
    @nav_item_map ||= {
        'my-proposals-link' => [
            starts_with_path(:proposals),
            starts_with_path(:event_event_proposals, current_event)
        ],
        'event-review-proposals-link' => starts_with_path(:event_staff_proposals, current_event),
        'event-selection-link' => selection_subnav_item_map,
        'event-program-link' => program_subnav_item_map,
        'event-schedule-link' => schedule_subnav_item_map,
        'event-dashboard-link' => event_subnav_item_map,
    }
  end

  def event_subnav_item_map
    @event_subnav_item_map ||= {
        'event-staff-dashboard-link' => exact_path(:event_staff, current_event),
        'event-staff-info-link' => [
            exact_path(:event_staff_info, current_event),
            exact_path(:event_staff_edit, current_event)
        ],
        'event-staff-teammates-link' => exact_path(:event_staff_teammates, current_event),
        'event-staff-config-link' => exact_path(:event_staff_config, current_event),
        'event-staff-guidelines-link' => exact_path(:event_staff_guidelines, current_event),
        'event-staff-speaker-emails-link' => exact_path(:event_staff_speaker_email_notifications, current_event),
    }
  end

  def selection_subnav_item_map
    @selection_subnav_item_map ||= {
        'event-program-proposals-selection-link' => [
            starts_with_path(:selection_event_staff_program_proposals, current_event),
        # add_path(:event_staff_program_proposal, current_event, @proposal)
        #How to leverage session[:prev_page] here? Considering lamdas
        ],
        'event-program-bulk-finalize-link' => starts_with_path(:bulk_finalize_event_staff_program_proposals, current_event),
        'event-program-proposals-link' => starts_with_path(:event_staff_program_proposals, current_event)
    }
  end

  def program_subnav_item_map
    @program_subnav_item_map ||= {
        'event-program-sessions-link' => starts_with_path(:event_staff_program_sessions, current_event),
        'event-program-speakers-link' => starts_with_path(:event_staff_program_speakers, current_event)
    }
  end

  def schedule_subnav_item_map
    @schedule_subnav_item_map ||= {
      'event-schedule-time-slots-link' => exact_path(:event_staff_schedule_time_slots, current_event),
      'event-schedule-rooms-link' => exact_path(:event_staff_schedule_rooms, current_event),
      'event-schedule-grid-link' => exact_path(:event_staff_schedule_grid, current_event)
    }
  end

  def exact_path(sym, *deps)
    send(sym.to_s + '_path', *deps) unless deps.include?(nil) # don't generate the path unless all dependencies are present
  end

  def starts_with_path(sym, *deps)
    starts_with = exact_path(sym, *deps)
    Regexp.new(Regexp.escape(starts_with) + ".*") if starts_with
  end
end
