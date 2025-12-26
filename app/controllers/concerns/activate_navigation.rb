require "active_support/concern"

module ActivateNavigation
  NAV_ITEM_MAP = {
    my_proposals: [->(p) { p.start_with?(path_for(Proposal)) }, ->(p) { p.start_with?(path_for(current_event, Proposal)) }],
    event_website: {
      event_website_configuration: ->(p) { p.start_with?(path_for(current_event, :staff, :website)) },
      event_pages: ->(p) { p == path_for(current_event, :staff, Page) }
    },
    event_review_proposals: ->(p) { p.start_with?(path_for(current_event, :staff, Proposal)) },
    event_selection: {
      event_program_proposals_selection: ->(p) { p.start_with?(path_for(:selection, current_event, :staff, :program, Proposal)) },
      event_program_bulk_finalize: ->(p) { p.start_with?(path_for(:bulk_finalize, current_event, :staff, :program, Proposal)) },
      event_program_proposals: ->(p) { p.start_with?(path_for(current_event, :staff, :program, Proposal)) }
    },
    event_program: {
      event_program_sessions: ->(p) { p.start_with?(path_for(current_event, :staff, ProgramSession)) },
      event_program_speakers: ->(p) { p.start_with?(path_for(current_event, :staff, :program, Speaker)) }
    },
    event_schedule: {
      event_schedule_time_slots: ->(p) { p == path_for(current_event, :staff, :schedule, TimeSlot) },
      event_schedule_rooms: ->(p) { p == path_for(current_event, :staff, :schedule, Room) },
      event_schedule_grid: ->(p) { p == path_for(current_event, :staff, :schedule, :grid) }
    },
    event_dashboard: {
      event_staff_dashboard: ->(p) { p == path_for(current_event, :staff) },
      event_staff_info: ->(pp) { [->(p) { p == path_for(:info, current_event, :staff) }, ->(p) { p == path_for(:edit, current_event, :staff) }].any? { it.call(pp) } },
      event_staff_teammates: ->(p) { p == path_for(current_event, :staff, Teammate) },
      event_staff_config: ->(p) { p == path_for(:config, current_event, :staff) },
      event_staff_guidelines: ->(p) { p == path_for(current_event, :staff, :guidelines) },
      event_staff_speaker_emails: ->(p) { p.start_with?(path_for(current_event, :staff, :speaker_email_templates)) }
    }
  }.freeze

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
    return if defined?(@active_nav_key)

    @active_nav_key, subnav_map = NAV_ITEM_MAP.find { |_, v| match?(v) }
    @active_subnav_key, _ = subnav_map.find { |_, v| instance_exec(request.path, &v) } if subnav_map.is_a?(Hash)
  end

  def match?(paths)
    case paths
    when Proc
      instance_exec(request.path, &paths)
    when Array
      paths.any? { |p| match?(p) }
    when Hash
      paths.any? { |_, v| match?(v) }
    end
  end

  def path_for(*args)
    url_for(args << {only_path: true})
  end
end
