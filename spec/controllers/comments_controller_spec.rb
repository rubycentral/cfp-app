require 'rails_helper'

describe CommentsController, type: :controller do
  describe "POST #create" do
    let(:proposal) { create(:proposal_with_track, uuid: 'abc123') }
    let(:mailer) { double("CommentNotificationMailer.speaker_notification") }

    context "Public comments" do
      let(:comment_user) { create(:reviewer, event: proposal.event) }
      let(:params) { { public_comment: { body: 'foo', proposal_id: proposal.id }, type: "PublicComment" } }

      before do
        sign_in comment_user
      end

      it "adds a comment to the proposal" do
        expect {
          post :create, params: params
        }.to change {PublicComment.count}.by(1)
      end

      it "sends an email notification to the speaker" do
        allow(CommentNotificationMailer).to receive(:speaker_notification).and_return(mailer)
        expect(mailer).to receive(:deliver_now)
        post :create, params: params
      end

      it "sends an email notification to all speakers" do
        speakers = build_list(:speaker, 3)
        proposal = create(:proposal_with_track, event: self.proposal.event, speakers: speakers)
        expect {
          post :create, params: { public_comment: { body: 'foo', proposal_id: proposal.id }, type: "PublicComment" }
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        email = ActionMailer::Base.deliveries.last
        expect(email.to).to match_array(speakers.map(&:email))
      end
    end

    context "Internal comments" do
      let(:params) { { internal_comment: { body: 'foo', proposal_id: proposal.id }, type: "InternalComment" } }
      let(:reviewer) { create(:reviewer, event: proposal.event) }

      before do
        sign_in reviewer
      end

      it "adds the comment to the proposal" do
        expect {
          post :create, params: params
        }.to change {InternalComment.count}.by(1)
      end

      it "does not send a notification email to the speaker" do
        expect(mailer).not_to receive(:deliver)
        post :create, params: params
      end
    end
  end
end
