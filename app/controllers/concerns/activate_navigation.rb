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
    return if defined?(@active_nav_key)

    @active_nav_key, subnav_map = nav_item_map.find { |_, v| match?(v) }
    @active_subnav_key, _ = subnav_map.find { |_, v| match?(v) } if subnav_map.is_a?(Hash)
  end

  def match?(paths)
    case paths
    when String
      paths == request.path
    when Regexp
      paths.match?(request.path)
    when Array
      paths.any? { |p| match?(p) }
    when Hash
      paths.any? { |_, v| match?(v) }
    end
  end

  def nav_item_map
    @nav_item_map ||= {
      my_proposals: [path_prefix(Proposal), path_prefix(current_event, Proposal)],
      event_website: website_subnav_item_map,
      event_review_proposals: path_prefix(current_event, :staff, Proposal),
      event_selection: selection_subnav_item_map,
      event_program: program_subnav_item_map,
      event_schedule: schedule_subnav_item_map,
      event_dashboard: event_subnav_item_map
    }
  end

  def event_subnav_item_map
    @event_subnav_item_map ||= {
      event_staff_dashboard: path_for(current_event, :staff),
      event_staff_info: [path_for(:info, current_event, :staff), path_for(:edit, current_event, :staff)],
      event_staff_teammates: path_for(current_event, :staff, Teammate),
      event_staff_config: path_for(:config, current_event, :staff),
      event_staff_guidelines: path_for(current_event, :staff, :guidelines),
      event_staff_speaker_emails: path_prefix(current_event, :staff, :speaker_email_templates)
    }
  end

  def website_subnav_item_map
    @website_subnav_item_map ||= {
      event_website_configuration: path_prefix(current_event, :staff, :website),
      event_pages: path_for(current_event, :staff, Page)
    }
  end

  def selection_subnav_item_map
    @selection_subnav_item_map ||= {
      event_program_proposals_selection: path_prefix(:selection, current_event, :staff, :program, Proposal),
      event_program_bulk_finalize: path_prefix(:bulk_finalize, current_event, :staff, :program, Proposal),
      event_program_proposals: path_prefix(current_event, :staff, :program, Proposal)
    }
  end

  def program_subnav_item_map
    @program_subnav_item_map ||= {
      event_program_sessions: path_prefix(current_event, :staff, ProgramSession),
      event_program_speakers: path_prefix(current_event, :staff, :program, Speaker)
    }
  end

  def schedule_subnav_item_map
    @schedule_subnav_item_map ||= {
      event_schedule_time_slots: path_for(current_event, :staff, :schedule, TimeSlot),
      event_schedule_rooms: path_for(current_event, :staff, :schedule, Room),
      event_schedule_grid: path_for(current_event, :staff, :schedule, :grid)
    }
  end

  def path_for(*args)
    url_for(args << {only_path: true}) unless args.include?(nil) # don't generate the path unless all dependencies are present
  end

  def path_prefix(*args)
    prefix = path_for(*args)
    /\A#{Regexp.escape(prefix)}/ if prefix
  end
end
