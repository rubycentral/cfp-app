require 'rails_helper'

describe ProposalsController, type: :controller do
  let(:event) { create(:event) }

  describe 'GET #new' do
    let(:user) { create :user }
    let(:action) { :new }
    let(:params) do
      { event_slug: event.slug }
    end

    before { sign_in user }

    context 'user profile is complete' do
      it 'should succeed' do
        get :new, params: { event_slug: event.slug }
        expect(response.status).to eq(200)
      end

      it 'does not return a flash warning' do
        get :new, params: { event_slug: event.slug }
        expect(flash[:warning]).not_to be_present
      end
    end

    context 'user profile is incomplete' do
      let(:lead_in_msg) { 'Before submitting a proposal your profile needs completing. Please correct the following:' }
      let(:trailing_msg) { ". Visit <a href=\"/profile/edit\">My Profile</a> to update." }

      it_behaves_like 'an incomplete profile notifier'
    end
  end

  describe 'POST #create' do
    let(:proposal) { build(:proposal_with_track, uuid: 'abc123') }
    let(:user) { create(:user) }
    let(:params) {
      {
        event_slug: event.slug,
        proposal: {
          title: proposal.title,
          abstract: proposal.abstract,
          details: proposal.details,
          pitch: proposal.pitch,
          session_format_id: proposal.session_format.id,
          speakers_attributes: {
            '0' => {
              bio: 'my bio'
            }
          }
        }
      }
    }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "sets the user's bio if not is present" do
      user.bio = nil
      post :create, params: params
      expect(user.bio).to eq('my bio')
    end
  end

  describe "POST #confirm" do
    it "confirms a proposal" do
      proposal = create(:proposal_with_track, state: :accepted, confirmed_at: nil)
      ProgramSession.create_from_proposal(proposal)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      allow(controller).to receive(:require_speaker).and_return(nil)
      post :confirm, params: {event_slug: proposal.event.slug, uuid: proposal.uuid}
      expect(proposal.reload).to be_confirmed
    end

  end

  describe "POST #update_notes" do
    it "sets confirmation_notes" do
      proposal = create(:proposal_with_track, confirmation_notes: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      allow(controller).to receive(:require_speaker).and_return(nil)
      post :update_notes, params: {event_slug: proposal.event.slug, uuid: proposal.uuid,
           proposal: {confirmation_notes: 'notes'}}
      expect(proposal.reload.confirmation_notes).to eq('notes')
    end
  end

  describe 'POST #withdraw' do
    let(:user) { create(:user) }
    let(:proposal) { create(:proposal_with_track, event: event) }
    before { allow(controller).to receive(:current_user).and_return(user) }
    before { allow(controller).to receive(:require_speaker).and_return(nil) }

    it "sets the state to withdrawn for unconfirmed proposals" do
      post :withdraw, params: {event_slug: event.slug, uuid: proposal.uuid}
      expect(proposal.reload).to be_withdrawn
    end

    it "leaves state unchanged for confirmed proposals" do
      proposal.update_attribute(:confirmed_at, Time.current)
      post :withdraw, params: {event_slug: event.slug, uuid: proposal.uuid}
      expect(proposal.reload).not_to be_withdrawn
    end

    it "sends an in-app notification to reviewers" do
      create(:rating, proposal: proposal, user: create(:reviewer, event: event))
      expect {
        post :withdraw, params: {event_slug: event.slug, uuid: proposal.uuid}
      }.to change { Notification.count }.by(1)
    end
  end

  describe 'POST #decline' do
    let!(:proposal) { create(:proposal_with_track, state: :accepted, confirmed_at: nil) }
    before { ProgramSession.create_from_proposal(proposal) }
    before { allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) } }
    before { allow(controller).to receive(:require_speaker).and_return(nil) }

    it "sets the state to withdrawn for unconfirmed proposals" do
      post :decline, params: {event_slug: proposal.event.slug, uuid: proposal.uuid}
      expect(proposal.reload).to be_withdrawn
    end

    it "sets the state to withdrawn for confirmed proposals" do
      proposal.update_attribute(:confirmed_at, Time.current)
      post :decline, params: {event_slug: proposal.event.slug, uuid: proposal.uuid}
      expect(proposal.reload).to be_withdrawn
    end

    it "changes the proposal program session state to declined" do
      expect {
        post :decline, params: {event_slug: proposal.event.slug, uuid: proposal.uuid}
      }.to change { proposal.program_session.reload.state }.to eq('declined')
    end
  end

  describe 'PUT #update' do
    let(:speaker) { create(:speaker) }
    let(:proposal) { create(:proposal_with_track, speakers: [ speaker ] ) }

    before { sign_in(speaker.user) }

    it "updates a proposals attributes" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')

        put :update, params: {event_slug: proposal.event.slug, uuid: proposal,
          proposal: { title: 'new_title', pitch: 'new_pitch' }}

       expect(proposal.reload).to have_attributes({title: 'new_title', pitch: 'new_pitch'})
       expect(proposal.abstract).to_not include('<p>')
       expect(proposal.abstract).to_not include('</p>')
    end

    it "sends a notifications to an organizer" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')
      organizer = create(:organizer, event: proposal.event)
      create(:rating, proposal: proposal, user: organizer)

      expect {
        put :update, params: {event_slug: proposal.event.slug, uuid: proposal,
          proposal: { abstract: proposal.abstract, title: 'new_title',
                      pitch: 'new_pitch' }}
      }.to change { Notification.count }.by(1)
    end
  end
end
