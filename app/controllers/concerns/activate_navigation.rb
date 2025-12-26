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
    @active_subnav_key, _ = find_first(subnav_map)
  end

  def find_first(item_map)
    return unless item_map.is_a?(Hash)

    item_map.find do |key, paths|
      match?(paths)
    end
  end

  def match?(paths)
    case paths
    when String
      paths == request.path
    when Regexp
      paths =~ request.path
    when Array
      paths.any? { |p| match?(p) }
    when Hash
      find_first(paths).present?
    end
  end

  def nav_item_map
    @nav_item_map ||= {
        'my-proposals-link' => [
            starts_with_path(Proposal),
            starts_with_path(current_event, Proposal)
        ],
        'event-website-link' => website_subnav_item_map,
        'event-review-proposals-link' => starts_with_path(current_event, :staff, Proposal),
        'event-selection-link' => selection_subnav_item_map,
        'event-program-link' => program_subnav_item_map,
        'event-schedule-link' => schedule_subnav_item_map,
        'event-dashboard-link' => event_subnav_item_map,
    }
  end

  def event_subnav_item_map
    @event_subnav_item_map ||= {
        'event-staff-dashboard-link' => path_for(current_event, :staff),
        'event-staff-info-link' => [
            path_for(:info, current_event, :staff),
            path_for(:edit, current_event, :staff)
        ],
        'event-staff-teammates-link' => path_for(current_event, :staff, Teammate),
        'event-staff-config-link' => path_for(:config, current_event, :staff),
        'event-staff-guidelines-link' => path_for(current_event, :staff, :guidelines),
        'event-staff-speaker-emails-link' => starts_with_path(current_event, :staff, :speaker_email_templates),
    }
  end

  def website_subnav_item_map
    @website_subnav_item_map ||= {
      'event-website-configuration-link' => starts_with_path(current_event, :staff, :website),
      'event-pages-link' => path_for(current_event, :staff, Page)
    }
  end

  def selection_subnav_item_map
    @selection_subnav_item_map ||= {
        'event-program-proposals-selection-link' => [
            starts_with_path(:selection, current_event, :staff, :program, Proposal),
        # add_path(:event_staff_program_proposal, current_event, @proposal)
        #How to leverage session[:prev_page] here? Considering lamdas
        ],
        'event-program-bulk-finalize-link' => starts_with_path(:bulk_finalize, current_event, :staff, :program, Proposal),
        'event-program-proposals-link' => starts_with_path(current_event, :staff, :program, Proposal)
    }
  end

  def program_subnav_item_map
    @program_subnav_item_map ||= {
        'event-program-sessions-link' => starts_with_path(current_event, :staff, ProgramSession),
        'event-program-speakers-link' => starts_with_path(current_event, :staff, :program, Speaker)
    }
  end

  def schedule_subnav_item_map
    @schedule_subnav_item_map ||= {
      'event-schedule-time-slots-link' => path_for(current_event, :staff, :schedule, TimeSlot),
      'event-schedule-rooms-link' => path_for(current_event, :staff, :schedule, Room),
      'event-schedule-grid-link' => path_for(current_event, :staff, :schedule, :grid)
    }
  end

  def path_for(*args)
    url_for(args << {only_path: true}) unless args.include?(nil) # don't generate the path unless all dependencies are present
  end

  def starts_with_path(sym, *deps)
    starts_with = path_for(sym, *deps)
    Regexp.new(Regexp.escape(starts_with) + ".*") if starts_with
  end
end
