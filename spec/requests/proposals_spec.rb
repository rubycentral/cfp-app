require 'rails_helper'

# Guards the proposal pages never offer a way to trip, so they are exercised by
# request rather than through the UI.
RSpec.describe 'Proposals', type: :request do
  let(:event) { create(:event, state: 'open') }
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'POST preview' do
    it "does not reveal speakers of other people's proposals" do
      other = create(:speaker, proposal: create(:proposal_with_track, event: event))
      post preview_event_proposals_path(event), params: {proposal: {speakers_attributes: {'0' => {id: other.id}}}}
      expect(response.body).not_to include(other.name)
    end
  end

  describe 'POST create' do
    it 'ignores demographic answers when the event does not ask for them' do
      create(:session_format)
      post event_proposals_path(event), params: {proposal: {
        title: 'A talk', abstract: 'About things', session_format_id: SessionFormat.last.id,
        speakers_attributes: {'0' => {bio: 'Me', age_range: '25-34 years old', pronouns: 'they/them/theirs',
                                      ethnicity: 'Asian', first_time_speaker: true}}}}
      speaker = Proposal.last.speakers.first
      expect([speaker.age_range, speaker.pronouns, speaker.ethnicity, speaker.first_time_speaker]).to all(be_nil)
    end
  end

  describe 'POST withdraw' do
    it 'leaves a confirmed proposal alone' do
      proposal = create(:proposal_with_track, event: event, state: :accepted, confirmed_at: Time.current)
      create(:speaker, proposal: proposal, user: user)
      post withdraw_event_proposal_path(event, proposal)
      expect(proposal.reload).to be_accepted
    end
  end

  describe 'POST decline' do
    it 'withdraws even a confirmed proposal' do
      proposal = create(:proposal_with_track, event: event, state: :accepted, confirmed_at: Time.current)
      ProgramSession.create_from_proposal(proposal)
      create(:speaker, proposal: proposal, user: user)
      post decline_event_proposal_path(event, proposal)
      expect(proposal.reload).to be_withdrawn
    end
  end
end
