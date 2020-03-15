class BulkFinalizeJob < ApplicationJob
  queue_as :default

  def perform(proposals_state)
    proposals = Proposal.where(state: proposals_state)

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
