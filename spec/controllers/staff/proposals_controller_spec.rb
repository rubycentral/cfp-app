require 'rails_helper'

describe Staff::ProposalsController, type: :controller do

  let(:event) { create(:event) }
  let(:user) do
    create(:user,
           organizer_teammates:
             [ create(:teammate, role: 'organizer', event: event) ],
          )
  end
  let(:proposal) { create(:proposal, event: event) }
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

  describe "POST 'update_session_format'" do
    let(:session_format) { create :session_format }

    it 'updates the format' do
      post :update_session_format, params: {event_slug: event, proposal_uuid: proposal.uuid, session_format_id: session_format.id}
      proposal.reload
      expect(proposal.session_format_id).to eq session_format.id
    end

    it 'renders the inline edit partial' do
      post :update_session_format, params: {event_slug: event, proposal_uuid: proposal.uuid, session_format_id: session_format.id}
      expect(response).to render_template partial: '_inline_format_edit'
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
      proposal = create(:proposal, event: event, state: Proposal::State::SOFT_ACCEPTED)
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
      expect(assigns(:proposal).state).to eq(Proposal::State::ACCEPTED)
    end

    it "creates a draft program session" do
      proposal = create(:proposal, event: event, state: Proposal::State::SOFT_ACCEPTED)
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
      expect(assigns(:proposal).program_session.state).to eq(ProgramSession::UNCONFIRMED_ACCEPTED)
    end

    it "sends appropriate emails" do
      proposal = create(:proposal, state: Proposal::State::SOFT_ACCEPTED)
      mail = double(:mail, deliver_now: nil)
      expect(Staff::ProposalMailer).to receive('send_email').and_return(mail)
      post :finalize, params: {event_slug: event, proposal_uuid: proposal.uuid}
    end

    it "creates a notification" do
      proposal = create(:proposal, :with_two_speakers, event: event, state: Proposal::State::SOFT_ACCEPTED)
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
      expect(response).to redirect_to(bulk_finalize_event_staff_program_proposals_path(event))
    end
  end

end
