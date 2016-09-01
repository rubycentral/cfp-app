require "active_support/concern"

module ActivateNavigation
  extend ActiveSupport::Concern

  included do
    helper_method :nav_item_class
    helper_method :program_subnav_item_class
    helper_method :event_subnav_item_class
  end

  def nav_item_class(key)
    map = {
      "/my-proposals" => "my-proposals-link",
      "/events/#{current_event.slug}/staff/proposals" => "event-review-proposals-link",
      "/events/#{current_event.slug}/staff/program/proposals/selection" => "event-program-link",
      "/events/#{current_event.slug}/staff/time_slots" => "event-schedule-link",
      "/events/#{current_event.slug}/staff" => "event-dashboard-link",
      "/events/#{current_event.slug}/staff/info" => "event-dashboard-link",
      "/events/#{current_event.slug}/staff/team" => "event-dashboard-link",
      "/events/#{current_event.slug}/staff/config" => "event-dashboard-link",
      "/events/#{current_event.slug}/staff/guidelines" => "event-dashboard-link",
      "/events/#{current_event.slug}/staff/speaker-emails" => "event-dashboard-link",
    }
    return "active" if key == map[request.path]
  end

  def event_subnav_item_class(key)
    map = {
      "/events/#{current_event.slug}/staff" => "event-staff-dashboard-link",
      "/events/#{current_event.slug}/staff/info" => "event-staff-info-link",
      "/events/#{current_event.slug}/staff/team" => "event-staff-teammates-link",
      "/events/#{current_event.slug}/staff/config" => "event-staff-config-link",
      "/events/#{current_event.slug}/staff/guidelines" => "event-staff-guidelines-link",
      "/events/#{current_event.slug}/staff/speaker-emails" => "event-staff-speaker-emails-link",
    }
    return "active" if key == map[request.path]
  end

  def program_subnav_item_class(key)
    map = {
      "/events/#{current_event.slug}/staff/program/proposals/selection" => "event-program-proposals-selection-link",
      "/events/#{current_event.slug}/staff/program/proposals" => "event-program-proposals-link",
      "/events/#{current_event.slug}/staff/program/sessions" => "event-program-sessions-link",
      "/events/#{current_event.slug}/staff/program/speakers" => "event-program-speakers-link",
    }
    return "active" if key == map[request.path]
  end
end
