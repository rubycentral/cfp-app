require 'rails_helper'

describe ProposalsController, type: :controller do
  let(:event) { create(:event) }

  describe 'GET #new' do
    let(:user) { create :user }

    before { sign_in user }

    context 'user profile is complete' do
      it 'should succeed' do
        get :new, { event_slug: event.slug }
        expect(response.status).to eq(200)
      end

      it 'does not return a flash message' do
        get :new, { event_slug: event.slug }
        expect(flash[:danger]).not_to be_present
      end
    end

    context 'user profile is incomplete' do
      let(:base_msg) { 'Before submitting a proposal your profile needs completing. Please correct the following:' }
      let(:unconfirmed_email_msg) { " Email #{user.unconfirmed_email} needs confirmation" }
      let(:link_msg) { ". Visit <a href=\"/profile\">My Profile</a> to update." }
      let(:blank_name_msg) { " Name can't be blank" }
      let(:blank_email_msg) { " Email can't be blank" }
      let(:blank_name_and_email_msg) { " Name can't be blank and Email can't be blank" }
      let(:unconfirmed_email_and_blank_name_msg) do
        " Name can't be blank and Email #{user.unconfirmed_email} needs confirmation"
      end

      it 'should succeed' do
        get :new, { event_slug: event.slug }
        expect(response.status).to eq(200)
      end

      context 'name is missing' do
        let(:msg) { base_msg + blank_name_msg + link_msg }

        before { user.update(name: nil) }

        it_behaves_like 'an incomplete profile notifier'
      end

      context 'email is missing' do
        let(:user) { create :user, email: '', provider: 'twitter' }
        let(:msg) { base_msg + blank_email_msg + link_msg }

        it_behaves_like 'an incomplete profile notifier'
      end

      context 'name and email are missing' do
        let(:user) { create :user, email: '', name: nil, provider: 'twitter' }
        let(:msg) do
          base_msg + blank_name_and_email_msg + link_msg
        end

        it_behaves_like 'an incomplete profile notifier'
      end

      context 'an unconfirmed email is present' do
        let(:msg) { base_msg + unconfirmed_email_msg + link_msg }

        before { user.update(unconfirmed_email: 'changed@email.com') }

        it_behaves_like 'an incomplete profile notifier'

        context 'name is missing' do
          let(:msg) do
            base_msg + unconfirmed_email_and_blank_name_msg + link_msg
          end

          before { user.update(name: nil) }

          it_behaves_like 'an incomplete profile notifier'
        end

        context 'email is missing' do
          let(:user) do
            create :user, email: '', provider: 'twitter'
          end
          let(:msg) { base_msg + unconfirmed_email_msg + link_msg }

          it_behaves_like 'an incomplete profile notifier'
        end
      end
    end
  end

  describe 'POST #create' do
    let(:proposal) { build_stubbed(:proposal, uuid: 'abc123') }
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
      post :create, params
      expect(user.bio).to eq('my bio')
    end
  end

  describe "POST #confirm" do
    it "confirms a proposal" do
      proposal = create(:proposal, confirmed_at: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      allow(controller).to receive(:require_speaker).and_return(nil)
      post :confirm, event_slug: proposal.event.slug, uuid: proposal.uuid
      expect(proposal.reload).to be_confirmed
    end

  end

  describe "POST #update_notes" do
    it "sets confirmation_notes" do
      proposal = create(:proposal, confirmation_notes: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      allow(controller).to receive(:require_speaker).and_return(nil)
      post :update_notes, event_slug: proposal.event.slug, uuid: proposal.uuid,
           proposal: {confirmation_notes: 'notes'}
      expect(proposal.reload.confirmation_notes).to eq('notes')
    end
  end

  describe 'POST #withdraw' do
    let(:proposal) { create(:proposal, event: event) }
    let(:user) { create(:user) }
    before { allow(controller).to receive(:current_user).and_return(user) }
    before { allow(controller).to receive(:require_speaker).and_return(nil) }

    it "sets the state to withdrawn for unconfirmed proposals" do
      post :withdraw, event_slug: event.slug, uuid: proposal.uuid
      expect(proposal.reload).to be_withdrawn
    end

    it "leaves state unchanged for confirmed proposals" do
      proposal.update_attribute(:confirmed_at, Time.now)
      post :withdraw, event_slug: event.slug, uuid: proposal.uuid
      expect(proposal.reload).not_to be_withdrawn
    end

    it "sends an in-app notification to reviewers" do
      create(:rating, proposal: proposal, user: create(:organizer))
      expect {
        post :withdraw, event_slug: event.slug, uuid: proposal.uuid
      }.to change { Notification.count }.by(1)
    end
  end

  describe 'PUT #update' do
    let(:speaker) { create(:speaker) }
    let(:proposal) { create(:proposal, speakers: [ speaker ] ) }

    before { sign_in(speaker.user) }

    it "updates a proposals attributes" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')

      put :update, event_slug: proposal.event.slug, uuid: proposal,
        proposal: { title: 'new_title', pitch: 'new_pitch' }

      expect(assigns(:proposal).title).to eq('new_title')
      expect(assigns(:proposal).pitch).to eq('new_pitch')
      expect(assigns(:proposal).abstract).to_not match('<p>')
      expect(assigns(:proposal).abstract).to_not match('</p>')
    end

    it "sends a notifications to an organizer" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')
      organizer = create(:organizer, event: proposal.event)
      create(:rating, proposal: proposal, user: organizer)

      expect {
        put :update, event_slug: proposal.event.slug, uuid: proposal,
          proposal: { abstract: proposal.abstract, title: 'new_title',
                      pitch: 'new_pitch' }
      }.to change { Notification.count }.by(1)
    end
  end
end
