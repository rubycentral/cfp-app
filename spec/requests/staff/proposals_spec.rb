require 'rails_helper'

RSpec.describe 'Staff proposals', type: :request do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer, event: event) }

  before { sign_in(organizer) }

  describe 'POST finalize_by_state' do
    it 'queues the bulk finalize job for the event and announces it' do
      create(:proposal_with_track, event: event, state: :soft_accepted)
      allow(ActionCable.server).to receive(:broadcast)

      expect {
        post finalize_by_state_event_staff_program_proposals_path(event), params: {proposals_state: 'soft_accepted'}
      }.to have_enqueued_job(BulkFinalizeJob).with(event, 'soft_accepted')

      expect(response).to have_http_status(:no_content)
      expect(ActionCable.server).to have_received(:broadcast).with('notifications', message: 'soft_accepted queued for finalization')
    end
  end
end
