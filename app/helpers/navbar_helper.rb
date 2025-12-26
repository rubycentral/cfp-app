module NavbarHelper
  NAV_ITEM_MAP = {
    my_proposals: ->(pp) { [->(p) { p.start_with?(path_for(Proposal)) }, ->(p) { p.start_with?(path_for(current_event, Proposal)) }].any? { it.call(pp) } },
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

  def nav_item_class(key)
    unless defined?(@active_nav_key)
      NAV_ITEM_MAP.find do |nav_key, nav_val|
        case nav_val
        when Proc
          @active_nav_key = nav_key if instance_exec(request.path, &nav_val)
        when Hash
          nav_val.find do |subnav_key, subnav_val|
            @active_nav_key, @active_subnav_key = nav_key, subnav_key if instance_exec(request.path, &subnav_val)
          end
        end
      end
    end

    'active' if @active_nav_key == key
  end

  def subnav_item_class(key)
    'active' if @active_subnav_key == key
  end

  private

  def path_for(*args)
    url_for(args << {only_path: true})
  end
end
