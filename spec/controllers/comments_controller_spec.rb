require 'rails_helper'

describe CommentsController, type: :controller do
  describe "POST #create" do
    let(:proposal) { create(:proposal, uuid: 'abc123') }
    let(:user) { create(:user) }
    let(:referer_path) { event_proposal_path(event_slug: proposal.event.slug, uuid: proposal) }
    let(:mailer) { double("CommentNotificationMailer.speaker_notification") }

    before do
      allow(Proposal).to receive(:find).and_return(proposal)
      request.env['HTTP_REFERER'] =  referer_path
    end

    context "Public comments" do
      let(:comment_user) { create(:user) }
      let(:comment) { create(:comment, type: "PublicComment", user: comment_user) }
      let(:params) { { public_comment: { body: 'foo', proposal_id: proposal.id }, type: "PublicComment" } }

      before do
        allow(comment_user).to receive(:reviewer?).and_return(true)
        allow(comment_user).to receive(:reviewer_for_event?).and_return(true)
        allow_any_instance_of(CommentsController).to receive(:current_user) { comment_user }
      end

      it "adds a comment to the proposal" do
        # expect(PublicComment).to receive(:create).and_return(comment)
        expect {
          post :create, params: params
        }.to change {PublicComment.count}.by(1)
      end

      it "returns to the referer" do
        post :create, params: params
        expect(response).to redirect_to(referer_path)
      end

      it "sends an email notification to the speaker" do
        allow(CommentNotificationMailer).to receive(:speaker_notification).and_return(mailer)
        expect(mailer).to receive(:deliver_now)
        post :create, params: params
      end

      it "sends an email notification to all speakers" do
        speakers = build_list(:speaker, 3)
        proposal = create(:proposal, speakers: speakers)
        allow(Proposal).to receive(:find).and_return(proposal)
        expect {
          post :create, params: params
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        email = ActionMailer::Base.deliveries.last
        expect(email.to).to match_array(speakers.map(&:email))
      end
    end

    context "Internal comments" do
      let(:comment) { build(:comment, type: "InternalComment") }
      let(:params) { { internal_comment: { body: 'foo', proposal_id: proposal.id }, type: "InternalComment" } }
      let(:reviewer) { build(:reviewer)}

      before do
        allow_any_instance_of(CommentsController).to receive(:current_user) { reviewer }
      end

      it "adds the comment to the proposal" do
        # expect(InternalComment).to receive(:create).and_return(comment)
        expect {
          post :create, params: params
        }.to change {InternalComment.count}.by(1)
      end

      it "returns to the referer" do
        post :create, params: params
        expect(response).to redirect_to(referer_path)
      end

      it "does not send a notification email to the speaker" do
        expect(mailer).not_to receive(:deliver)
        post :create, params: params
      end
    end
  end
end
