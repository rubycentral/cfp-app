require "active_support/concern"

module ProgramSupport
  extend ActiveSupport::Concern

  included do
    before_action :require_program_team
    before_action :set_proposal_counts

    helper_method :sticky_selected_track
  end

  private

  def sticky_selected_track
    session["event/#{current_event.id}/program/track"] if current_event
  end

  def sticky_selected_track=(id)
    session["event/#{current_event.id}/program/track"] = id if current_event
  end

  def set_proposal_counts
    @all_accepted_count ||= current_event.stats.all_accepted_proposals
    @all_waitlisted_count ||= current_event.stats.all_waitlisted_proposals
    unless sticky_selected_track == 'all'
      @all_accepted_track_count ||= current_event.stats.all_accepted_proposals(sticky_selected_track)
      @all_waitlisted_track_count ||= current_event.stats.all_waitlisted_proposals(sticky_selected_track)
    end
  end

end
