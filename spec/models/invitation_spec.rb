require 'rails_helper'

describe Invitation do
  let!(:user) { create(:user, email: 'foo@example.com') }
  let(:proposal) { create(:proposal) }
  let(:invitation) { create(:invitation, email: 'foo@example.com', slug: 'foo', proposal: proposal) }

  describe "#create" do
    it "sets the slug" do
      invitation = build(:invitation, slug: nil)
      digest = 'deadbeef2014'
      expect(Digest::SHA1).to receive(:hexdigest).and_return(digest)
      invitation.save
      expect(invitation.slug).to eq('deadbeef20')
    end
  end

  describe "#decline" do
    it "sets state as declined" do
      invitation = create(:invitation, state: nil)
      invitation.decline
      expect(invitation.state).to eq(Invitation::State::DECLINED)
    end
  end

  describe "#accept" do
    it "sets state as accepted" do
      invitation.accept(user)
      expect(invitation.state).to eq(Invitation::State::ACCEPTED)
    end

    it "sets the user on the invitation" do
      invitation.accept(user)
      expect(invitation.user).to eq(user)
    end

    it "creates an associated speaker record" do
      invitation.accept(user)
      expect(proposal.has_speaker?(user)).to eq(true)
    end
  end

  describe "#pending?" do
    it "returns true if invitation is pending" do
      invitation = create(:invitation, state: Invitation::State::PENDING)
      expect(invitation).to be_pending
    end

    it "returns false if invitation is not pending" do
      invitation = create(:invitation, state: Invitation::State::ACCEPTED)
      expect(invitation).to_not be_pending
    end
  end

  describe "#declined?" do
    it "returns true if invitation was declined" do
      invitation = create(:invitation, state: Invitation::State::DECLINED)
      expect(invitation).to be_declined
    end

    it "returns false if invitation was not declined" do
      invitation = create(:invitation, state: Invitation::State::ACCEPTED)
      expect(invitation).to_not be_declined
    end
  end
end
