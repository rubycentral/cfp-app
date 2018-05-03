# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinalizationNotifier do
  include FinalizationMessages

  describe '.notify' do
    let(:user)     { create(:user) }
    let(:event)    { create(:event) }
    let(:proposal) { create(:proposal, :with_two_speakers, event: event, state: Proposal::State::ACCEPTED) }

    it 'calls Staff::ProposalMailer.send_email' do
      allow(Staff::ProposalMailer).to receive_message_chain(':send_email.delivier_now')
      expect(Staff::ProposalMailer)
        .to receive(:send_email)
          .exactly(1).times
          .with(proposal) { Struct.new(:deliver_now).new }

      described_class.notify(proposal)
    end

    it 'calls Notification.create_for' do
      expect(Notification)
        .to receive(:create_for_all)
        .exactly(1).times
        .with(proposal.speakers.map(&:user), proposal: proposal, message: subject_for(proposal: proposal))

      described_class.notify(proposal)
    end
  end
end
