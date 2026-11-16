require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:event) { create(:event) }
  let(:proposal) { create(:proposal_with_track, event: event) }
  let(:speaker_user) { create(:user) }
  let!(:speaker) { create(:speaker, :with_name, :with_email, proposal: proposal, event: event, user: speaker_user) }
  let(:reviewer) { create(:reviewer, event: event) }
  let(:outsider) { create(:user) }

  def post_public_comment
    post public_comments_path, params: {public_comment: {body: 'A public remark', proposal_id: proposal.id}, type: 'PublicComment'}
  end

  def post_internal_comment(body: 'A private remark')
    post internal_comments_path, params: {internal_comment: {body: body, proposal_id: proposal.id}, type: 'InternalComment'}
  end

  context 'when not signed in' do
    it 'does not create a comment' do
      expect { post_public_comment }.not_to change(Comment, :count)
      expect(response).to redirect_to(new_session_url)
    end
  end

  context 'as a signed-in user with no role on the event' do
    before { sign_in outsider }

    it 'cannot post a public comment' do
      expect { post_public_comment }.not_to change(Comment, :count)
      expect(response).to redirect_to(root_path)
      expect(flash[:danger]).to eq('You are not allowed to comment on the proposal you are trying to access.')
    end

    it 'cannot post an internal comment, even one @mentioning event staff' do
      mention_name = reviewer.teammates.first.mention_name

      expect { post_internal_comment(body: "@#{mention_name} please look at this") }
        .to change(Comment, :count).by(0)
        .and change(Notification, :count).by(0)
        .and change(ActionMailer::Base.deliveries, :count).by(0)
      expect(response).to redirect_to(root_path)
      expect(flash[:danger]).to eq('You are not allowed to comment on the proposal you are trying to access.')
    end
  end

  context 'as a speaker on the proposal' do
    before { sign_in speaker_user }

    it 'can post a public comment' do
      expect { post_public_comment }.to change(PublicComment, :count).by(1)
      expect(PublicComment.last).to have_attributes(user: speaker_user, proposal: proposal, body: 'A public remark')
      expect(response).to redirect_to(event_proposal_path(event, proposal))
    end

    it 'cannot post an internal comment' do
      expect { post_internal_comment }.not_to change(Comment, :count)
      expect(response).to redirect_to(root_path)
      expect(flash[:danger]).to eq('You are not allowed to comment on the proposal you are trying to access.')
    end

    it 'cannot post an internal comment on their own proposal even when they are event staff' do
      create(:teammate, :reviewer, event: event, user: speaker_user)

      expect { post_internal_comment }.not_to change(Comment, :count)
      expect(response).to redirect_to(root_path)
    end
  end

  context 'as event staff' do
    before { sign_in reviewer }

    it 'can post a public comment' do
      expect { post_public_comment }.to change(PublicComment, :count).by(1)
      expect(PublicComment.last).to have_attributes(user: reviewer, proposal: proposal)
      expect(response).to redirect_to(event_proposal_path(event, proposal))
    end

    it 'can post an internal comment' do
      expect { post_internal_comment }.to change(InternalComment, :count).by(1)
      expect(InternalComment.last).to have_attributes(user: reviewer, proposal: proposal, body: 'A private remark')
      expect(response).to redirect_to(event_proposal_path(event, proposal))
    end

    it 'cannot comment on a proposal in another event' do
      other_proposal = create(:proposal_with_track)

      expect {
        post public_comments_path, params: {public_comment: {body: 'Hi', proposal_id: other_proposal.id}, type: 'PublicComment'}
      }.not_to change(Comment, :count)
      expect(response).to redirect_to(root_path)
    end
  end
end
