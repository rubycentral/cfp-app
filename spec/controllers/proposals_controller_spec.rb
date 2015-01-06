require 'rails_helper'

describe ProposalsController, type: :controller do
  let(:event) { create(:event) }

  describe 'GET #new' do
    before {
      allow(@controller).to receive(:require_user) { true }
    }

    it 'should succeed' do
      get :new, slug: event.slug
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    let(:proposal) { build_stubbed(:proposal, uuid: 'abc123') }
    let(:user) { create(:person) }
    let(:params) {
      {
        slug: event.slug,
        proposal: {
          title: proposal.title,
          abstract: proposal.abstract,
          details: proposal.details,
          pitch: proposal.pitch,
          speakers_attributes: {
            '0' => {
              bio: 'my bio',
              person_id: user.id
            }
          }
        }
      }
    }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "sets the user's bio if not is present" do
      user.bio = nil
      post :create, params
      expect(user.bio).to eq('my bio')
    end

    context "With completed demgraphics" do
      it "redirects to the new proposal" do
        allow(user).to receive(:demographics_complete?).and_return(true)
        post :create, params
        expect(response).to redirect_to(proposal_path(slug: event.slug,
                                                      uuid: assigns(:proposal).uuid)
                                       )
      end
    end

    context "With incomplete demographics" do
      it "redirects to the profile page" do
        allow(user).to receive(:demographics_complete?).and_return(false)
        post :create, params
        expect(response).to redirect_to(edit_profile_path)
      end
    end
  end

  describe "GET #confirm" do
    it "allows any user with an accepted proposal" do
      authorized = create(:speaker)
      unauthorized = create(:speaker)
      proposal = create(:proposal, event: event, speakers: [ authorized ], state: "accepted")
      allow_any_instance_of(ProposalsController).to receive(:current_user) { unauthorized.person }
      post :confirm, slug: event.slug, uuid: proposal.uuid
      expect(response).to be_success
    end
  end

  describe "POST #set_confirmed" do
    it "confirms a proposal" do
      proposal = create(:proposal, confirmed_at: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      post :set_confirmed, slug: proposal.event.slug, uuid: proposal.uuid
      expect(proposal.reload).to be_confirmed
    end

    it "can set confirmation_notes" do
      proposal = create(:proposal, confirmation_notes: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      post :set_confirmed, slug: proposal.event.slug, uuid: proposal.uuid,
        confirmation_notes: 'notes'
      expect(proposal.reload.confirmation_notes).to eq('notes')
    end
  end

  describe 'POST #withdraw' do
    let(:proposal) { create(:proposal, event: event) }
    let(:user) { create(:person) }
    before { allow(controller).to receive(:current_user).and_return(user) }

    it "sets the state to withdrawn for unconfirmed proposals" do
      post :withdraw, slug: event.slug, uuid: proposal.uuid
      expect(proposal.reload).to be_withdrawn
    end

    it "leaves state unchanged for confirmed proposals" do
      proposal.update_attribute(:confirmed_at, Time.now)
      post :withdraw, slug: event.slug, uuid: proposal.uuid
      expect(proposal.reload).not_to be_withdrawn
    end

    it "sends an in-app notification to reviewers" do
      create(:rating, proposal: proposal, person: create(:organizer))
      expect {
        post :withdraw, slug: event.slug, uuid: proposal.uuid
      }.to change { Notification.count }.by(1)
    end
  end

  describe 'PUT #update' do
    let(:speaker) { create(:speaker) }
    let(:proposal) { create(:proposal, speakers: [ speaker ] ) }

    before { login(speaker.person) }

    it "updates a proposals attributes" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')

      put :update, slug: proposal.event.slug, uuid: proposal,
        proposal: { title: 'new_title', pitch: 'new_pitch' }

      expect(assigns(:proposal).title).to eq('new_title')
      expect(assigns(:proposal).pitch).to eq('new_pitch')
    end

    it "sends a notifications to an organizer" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')
      organizer = create(:organizer, event: proposal.event)
      create(:rating, proposal: proposal, person: organizer)

      expect {
        put :update, slug: proposal.event.slug, uuid: proposal,
          proposal: { abstract: proposal.abstract, title: 'new_title',
                      pitch: 'new_pitch' }
      }.to change { Notification.count }.by(1)
    end
  end
end
