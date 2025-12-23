require 'rails_helper'

describe Staff::ProposalsController, type: :controller do

  let(:event) { create(:event) }
  let(:user) do
    create(:user,
           organizer_teammates:
             [ create(:teammate, role: 'organizer', event: event) ],
          )
  end
  let(:proposal) { create(:proposal_with_track, event: event) }
  let(:reviewer) { create(:user, :reviewer) }

  before do
    sign_in(user)
  end

  describe '#index' do
    it "should respond" do
      get :index, params: {event_slug: proposal.event.slug}
      expect(response.status).to eq(200)
    end
  end

  describe "GET 'show'" do
    it "marks all notifications for this proposal as read" do
      Notification.create_for(user, proposal: proposal, message: "A fancy notification")
      expect{
        get :show, params: {event_slug: event, uuid: proposal.uuid}
      }.to change {user.notifications.unread.count}.by(-1)
    end
  end

  describe "PATCH 'update'" do
    let(:session_format) { create :session_format }
    let(:track) { create :track, event: event }

    it 'updates the session_format' do
      patch :update, params: {event_slug: event, uuid: proposal.uuid, proposal: {session_format_id: session_format.id}}, as: :turbo_stream
      proposal.reload

      expect(proposal.session_format_id).to eq session_format.id
    end

    it 'updates the track' do
      patch :update, params: {event_slug: event, uuid: proposal.uuid, proposal: {track_id: track.id}}, as: :turbo_stream
      proposal.reload

      expect(proposal.track_id).to eq track.id
    end
  end

  describe "POST 'update_state'" do
    it "returns http redirect" do
      post :update_state, params: {event_slug: event, proposal_uuid: proposal.uuid}
      expect(response).to redirect_to(event_staff_program_proposals_path(event))
    end
  end

  describe "POST 'finalize'" do
    it "returns http redirect" do
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
      expect(response).to redirect_to(event_staff_program_proposal_path(event, proposal))
    end

    it "finalizes the state" do
      proposal = create(:proposal_with_track, event: event, state: :soft_accepted)
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
      expect(proposal.reload).to be_accepted
    end

    it "creates a draft program session" do
      proposal = create(:proposal_with_track, event: event, state: :soft_accepted)
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
      expect(proposal.program_session).to be_unconfirmed_accepted
    end

    it "sends appropriate emails" do
      proposal = create(:proposal_with_track, event: event, state: :soft_accepted)
      mail = double(:mail, deliver_now: nil)
      expect(Staff::ProposalMailer).to receive('send_email').and_return(mail)
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
    end

    it "creates a notification" do
      proposal = create(:proposal_with_track, :with_two_speakers, event: event, state: :soft_accepted)
      expect {
        post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
      }.to change {
        Notification.count
      }.by(2)
    end
  end

  describe "GET 'bulk_finalize'" do
    it "should respond" do
      get :bulk_finalize, params: {event_slug: event.slug}
      expect(response.status).to eq(200)
    end
  end

  describe "POST 'finalize_by_state'" do
    it "returns http redirect" do
      post :finalize_by_state, params: {event_slug: event, proposals_state: proposal.state}
      expect(response.status).to eq(204)
    end
  end
end
