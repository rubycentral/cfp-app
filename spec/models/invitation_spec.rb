require 'rails_helper'

describe Invitation do
  describe "#create" do
    let!(:person) { create(:person, email: 'foo@example.com') }
    let(:proposal) { create(:proposal) }
    let(:invitation) { create(:invitation, email: 'foo@example.com', slug: 'foo', proposal: proposal) }

    context "When a person record matches by email" do
      it "locates the person record" do
        expect(Person).to receive(:where).and_return([person])
        create(:invitation, email: 'foo@example.com', slug: 'foo', proposal: proposal)
      end

      it "assigns the person record to the invitation" do
        invitation.reload
        expect(invitation.person).to eq(person)
      end
    end

    it "sets the slug" do
      invitation = build(:invitation, slug: nil)
      digest = 'deadbeef2014'
      expect(Digest::SHA1).to receive(:hexdigest).and_return(digest)
      invitation.save
      expect(invitation.slug).to eq('deadbeef20')
    end
  end

  describe "#refuse" do
    it "sets state as refused" do
      invitation = create(:invitation, state: nil)
      invitation.refuse
      expect(invitation.state).to eq(Invitation::State::REFUSED)
    end
  end

  describe "#accept" do
    it "sets state as accepted" do
      invitation = create(:invitation, state: nil)
      invitation.accept
      expect(invitation.state).to eq(Invitation::State::ACCEPTED)
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

  describe "#refused?" do
    it "returns true if invitation was refused" do
      invitation = create(:invitation, state: Invitation::State::REFUSED)
      expect(invitation).to be_refused
    end

    it "returns false if invitation was not refused" do
      invitation = create(:invitation, state: Invitation::State::ACCEPTED)
      expect(invitation).to_not be_refused
    end
  end
end
