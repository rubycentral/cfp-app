require 'rails_helper'

RSpec.describe BulkFinalizeJob do
  let(:event) { create(:event) }

  it 'finalizes every proposal in the given soft state, notifying their speakers and the page' do
    accepted = create(:proposal_with_track, event: event, state: :soft_accepted)
    speaker = create(:speaker, proposal: accepted)
    untouched = create(:proposal_with_track, event: event, state: :soft_rejected)
    create(:speaker, proposal: untouched)
    allow(ActionCable.server).to receive(:broadcast)

    expect {
      described_class.perform_now('soft_accepted')
    }.to change(ActionMailer::Base.deliveries, :count).by(1)

    expect(accepted.reload).to be_accepted
    expect(accepted.program_session).to be_present
    expect(speaker.user.notifications.count).to eq(1)
    expect(untouched.reload).to be_soft_rejected

    expect(ActionCable.server).to have_received(:broadcast)
      .with('notifications', message: 'Finalizing 1 soft_accepted proposals...')
    expect(ActionCable.server).to have_received(:broadcast)
      .with('notifications', hash_including(message: 'Bulk Finalize complete!', complete: '1', state: 'soft_accepted'))
  end
end
