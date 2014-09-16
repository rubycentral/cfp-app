namespace :proposals do

  desc "Reject Proposal"
  task :reject, [:proposal_id] => :environment do |t, args|
    proposal = Proposal.find args[:proposal_id]
    reject_proposal(proposal.event, proposal)
  end

  desc "Reject all 'submitted' & 'soft rejected'  proposals"
  task :reject_all_submitted_and_soft_rejected, [:event_slug]  => :environment do |t, args|
    event = Event.where(slug: args[:event_slug]).first

    unless event
      raise "No event found for #{args[:event_slug]}"
    end
    puts "Event: #{event.name}"
    puts "  found #{event.proposals.submitted.size} proposals in submitted state"
    puts "  found #{event.proposals.soft_rejected.size} proposals in soft rejected state"
    collected_proposals = event.proposals.submitted + event.proposals.soft_rejected
    collected_proposals.each do |proposal|
      reject_proposal(event, proposal)
    end
  end

  def reject_proposal(event, proposal)
    puts "rejecting: #{proposal.id}: #{proposal.speakers.first.email} - #{proposal.title}"
    proposal.update_state(Proposal::State::REJECTED)
    Organizer::ProposalMailer.reject_email(event, proposal).deliver
  end
end
