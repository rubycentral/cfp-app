require 'rails_helper'

describe CommentsController, type: :controller do
  describe "POST #create" do
    let(:proposal) { build_stubbed(:proposal, uuid: 'abc123') }
    let(:person) { build_stubbed(:person) }
    let(:referer_path) { proposal_path(slug: proposal.event.slug, uuid: proposal) }
    let(:mailer) { double("ProposalMailer.comment_notification") }

    before do
      allow(Proposal).to receive(:find).and_return(proposal)
      request.env['HTTP_REFERER'] =  referer_path
    end

    context "Public comments" do
      let(:comment_person) { build_stubbed(:person) }
      let(:comment) { build_stubbed(:comment, type: "PublicComment", person: comment_person) }
      let(:params) { { public_comment: { body: 'foo', proposal_id: proposal.id }, type: "PublicComment" } }

      before do
        allow(comment_person).to receive(:reviewer?).and_return(true)
        allow(comment_person).to receive(:reviewer_for_event?).and_return(true)
        allow_any_instance_of(CommentsController).to receive(:current_user) { comment_person }
      end

      it "adds a comment to the proposal" do
        # expect(PublicComment).to receive(:create).and_return(comment)
        expect {
          post :create, params
        }.to change {PublicComment.count}.by(1)
      end

      it "returns to the referer" do
        post :create, params
        expect(response).to redirect_to(referer_path)
      end

      it "sends an email notification to the speaker" do
        allow(ProposalMailer).to receive(:comment_notification).and_return(mailer)
        expect(mailer).to receive(:deliver)
        post :create, params
      end

      it "sends an email notification to all speakers" do
        speakers = build_list(:speaker, 3)
        proposal = create(:proposal, speakers: speakers)
        allow(Proposal).to receive(:find).and_return(proposal)
        expect {
          post :create, params
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        email = ActionMailer::Base.deliveries.last
        expect(email.bcc).to match_array(speakers.map(&:email))
      end
    end

    context "Internal comments" do
      let(:comment) { build_stubbed(:comment, type: "InternalComment") }
      let(:params) { { internal_comment: { body: 'foo', proposal_id: proposal.id }, type: "InternalComment" } }
      let(:reviewer) { build_stubbed(:reviewer)}

      before do
        allow_any_instance_of(CommentsController).to receive(:current_user) { reviewer }
      end

      it "adds the comment to the proposal" do
        # expect(InternalComment).to receive(:create).and_return(comment)
        expect {
          post :create, params
        }.to change {InternalComment.count}.by(1)
      end

      it "returns to the referer" do
        post :create, params
        expect(response).to redirect_to(referer_path)
      end

      it "does not send a notification email to the speaker" do
        expect(mailer).not_to receive(:deliver)
        post :create, params
      end
    end
  end
end
