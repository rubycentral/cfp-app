require 'rails_helper'

describe Staff::ProposalsController, type: :controller do

  let(:event) { create(:event) }
  let(:user) do
    create(:user,
           organizer_teammates:
             [ build(:teammate, role: 'organizer', event: event) ],
          )
  end
  let(:proposal) { create(:proposal, event: event) }
  let(:reviewer) { create(:user, :reviewer) }

  before do
    sign_in(user)
  end

  describe '#index' do
    it "should respond" do
      get :index, event_slug: proposal.event.slug
      expect(response.status).to eq(200)
    end
  end

  describe "GET 'show'" do
    it "marks all notifications for this proposal as read" do
      Notification.create_for([user], proposal: proposal, message: "A fancy notification")
      expect{
        get :show, {event_slug: event, uuid: proposal.uuid}
      }.to change {user.notifications.unread.count}.by(-1)
    end
  end

  describe "POST 'update_state'" do
    it "returns http redirect" do
      post 'update_state', event_slug: event, proposal_uuid: proposal.uuid
      expect(response).to redirect_to(event_staff_proposals_path(event))
    end
  end

  describe "POST 'finalize'" do
    it "returns http redirect" do
      post :finalize, event_slug: event, proposal_uuid: proposal.uuid
      expect(response).to redirect_to(event_staff_proposal_path(event, proposal))
    end

    it "finalizes the state" do
      proposal = create(:proposal, event: event, state: Proposal::State::SOFT_ACCEPTED)
      post :finalize, event_slug: event, proposal_uuid: proposal.uuid
      expect(assigns(:proposal).state).to eq(Proposal::State::ACCEPTED)
    end

    it "sends appropriate emails" do
      state_to_email = {
        Proposal::State::SOFT_ACCEPTED => :accept_email,
        Proposal::State::SOFT_WAITLISTED => :waitlist_email,
        Proposal::State::SOFT_REJECTED => :reject_email
      }

      state_to_email.each do |state, mail_action|
        proposal = create(:proposal, state: state)
        mail = double(:mail, deliver_now: nil)
        expect(Staff::ProposalMailer).to receive(mail_action).and_return(mail)
        post :finalize, event_slug: event, proposal_uuid: proposal.uuid
      end
    end
  end

  context "reviewer has a submitted proposal" do
    let!(:speaker) { create(:speaker, user: reviewer) }
    let!(:speaker_proposal) { create(:proposal, speakers: [ speaker ], event: event) }

    before :each do
      sign_out(user)
      sign_in(reviewer)
    end


    it "prevents reviewers from viewing their own proposals" do
      get :show, event_slug: event.slug, uuid: speaker_proposal
      expect(response).to redirect_to(event_staff_proposals_path(event_slug: event.slug))
    end

    it "prevents reviewers from updating their own proposals" do
      get :update, event_slug: event.slug, uuid: speaker_proposal,
        proposal: { review_tags: [ 'tag' ] }
      expect(speaker_proposal.review_tags).to_not eq([ 'tag' ])
    end
  end

end
