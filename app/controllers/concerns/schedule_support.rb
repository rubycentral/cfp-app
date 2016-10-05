require "active_support/concern"

module ScheduleSupport
  extend ActiveSupport::Concern

  included do
    before_action :require_organizer
    before_action :enable_staff_schedule_subnav
  end

end
