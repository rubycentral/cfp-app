class Organizer::ProgramController < Organizer::ApplicationController
  def show
    accepted_proposals =
      @event.proposals.includes(:session).for_state([Proposal::State::ACCEPTED, Proposal::State::SOFT_ACCEPTED])

    waitlisted_proposals = @event.proposals.for_state(Proposal::State::WAITLISTED)

    session[:prev_page] = { name: 'Program', path: organizer_event_program_path(@event) }

    respond_to do |format|
      format.html do
        render locals: {
          accepted_proposals:
            ProposalDecorator.decorate_collection(accepted_proposals),
          waitlisted_proposals:
            ProposalDecorator.decorate_collection(waitlisted_proposals),
          accepted_confirmed_count: accepted_proposals.to_a.count(&:confirmed?),
          waitlisted_confirmed_count: waitlisted_proposals.to_a.count(&:confirmed?)
        }
      end

      format.json { render_json(accepted_proposals.confirmed) }
    end
  end
end
