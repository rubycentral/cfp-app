class BulkFinalizeJob < ApplicationJob
  queue_as :default

  def perform(proposals_state)
    proposals = Proposal.where(state: proposals_state)
    proposals.each do |proposal|
      proposal.finalize
      FinalizationNotifier.notify(proposal) unless proposal.changed?
    end
  end
end
