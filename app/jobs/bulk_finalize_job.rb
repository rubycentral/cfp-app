class BulkFinalizeJob < ApplicationJob
  queue_as :default

  def perform(event, proposals_state)
    proposals = event.proposals.where(state: proposals_state)

    ActionCable.server.broadcast "notifications", {
      message: "Finalizing #{proposals.size} #{proposals_state} proposals..."
    }

    proposals.each do |proposal|
      proposal.finalize
      FinalizationNotifier.notify(proposal) unless proposal.changed?
    end

    ActionCable.server.broadcast "notifications", {
      message: "Bulk Finalize complete!",
      complete: "1",
      state: proposals_state.gsub(/\s+/, '-')
    }
  end
end
