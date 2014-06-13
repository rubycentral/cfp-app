require 'rails_helper'

include Proposal::State

describe Proposal do
  describe "scope :unrated" do
    it "returns all unrated proposals" do
      rated = create_list(:proposal, 3)
      unrated = create_list(:proposal, 5)
      rated.each { |proposal| create(:rating, proposal: proposal) }

      expect(Proposal.unrated).to match_array(unrated)
    end
  end

  describe "scope :rated" do
    it "returns all rated proposals" do
      rated = create_list(:proposal, 3)
      unrated = create_list(:proposal, 5)
      rated.each { |proposal| create(:rating, proposal: proposal) }

      expect(Proposal.rated).to match_array(rated)

    end
  end

  describe "scope :available" do
    it "shows a previously assigned but removed proposal as available" do
      proposal = create(:proposal, state: ACCEPTED)
      conf_session = create(:session, proposal: proposal, event: proposal.event)

      expect {
        conf_session.destroy
      }.to change{Proposal.available.count}.by(1)
    end

    it "only shows accepted proposals" do
      create(:proposal, state: WAITLISTED)
      proposal = create(:proposal, state: ACCEPTED)

      expect(Proposal.available).to match_array([ proposal ])
    end

    it "sorts proposals by talk title" do
      zebra = create(:proposal, title: 'Zebra', state: ACCEPTED)
      theta = create(:proposal, title: 'Theta', state: ACCEPTED)
      alpha = create(:proposal, title: 'Alpha', state: ACCEPTED)
      expect(Proposal.available).to eq([ alpha, theta, zebra ])
    end
  end

  describe "scope :emails" do
    it "returns all attached email addresses" do
      person1 = create(:person, email: 'person1@test.com')
      person2 = create(:person, email: 'person2@test.com')

      create(:proposal, speakers: [ create(:speaker, person: person1) ])
      create(:proposal, speakers: [ create(:speaker, person: person2) ])

      emails = Proposal.all.emails
      expect(emails).to match_array([ person1.email, person2.email ])
    end
  end

  context "When the record is new" do
    let(:proposal) { build(:proposal, title: 'Dioramas!', abstract: 'Are great!') }

    it 'sets a UUID before creation' do
      expect(Digest::SHA1).to receive(:hexdigest) { 'greendalecollege'}
      expect{proposal.save}.to change{proposal.uuid}.from(nil).to('greendalec')
    end

    it "limits abstracts to 600 characters or less" do
      build(:proposal, abstract: "S" * 600).should be_valid
      build(:proposal, abstract: "S" * 601).should_not be_valid
    end
  end

  describe "state methods" do
    let(:state_method_map) do
      {
        SUBMITTED => :draft?,
        WITHDRAWN => :withdrawn?,
        ACCEPTED => :accepted?,
        WAITLISTED => :waitlisted?
      }
    end

    it "returns true if the state matches the method" do
      state_method_map.each do |state, method|
        proposal = create(:proposal, state: state)
        expect(proposal.public_send(method)).to be_truthy
      end
    end

    it "returns false if the state doesn't match" do
      state_method_map.each do |state, method|
        diff_state = state
        while diff_state == state
          # Get a random state
          diff_state = Proposal::State.const_get(Proposal::State.constants.sample)
        end

        proposal = create(:proposal, state: state)
        expect(proposal.public_send(method)).to be_truthy
      end
    end
  end

  describe "#confirmed?" do
    it "returns true if proposal has been confirmed" do
      proposal = create(:proposal, confirmed_at: DateTime.now)
      expect(proposal).to be_confirmed
    end

    it "returns false if proposal has not been confirmed" do
      proposal = create(:proposal, confirmed_at: nil)
      expect(proposal).to_not be_confirmed
    end
  end

  describe "#scheduled?" do
    let(:proposal) { build_stubbed(:proposal, state: ACCEPTED) }

    it "returns true for scheduled proposals" do
      create(:session, proposal: proposal)
      expect(proposal).to be_scheduled
    end

    it "returns false for proposals that are not yet scheduled." do
      expect(proposal).to_not be_scheduled
    end
  end

  describe "state changing" do
    describe "#finalized?" do
      it "returns false for all soft states" do
        soft_states = [ SOFT_ACCEPTED, SOFT_WITHDRAWN, SOFT_WAITLISTED,
                        SOFT_REJECTED, SUBMITTED ]

        soft_states.each do |state|
          proposal = create(:proposal, state: state)
          expect(proposal).to_not be_finalized
        end
      end

      it "returns true for all finalized states" do
        finalized_states = Proposal::FINAL_STATES

        finalized_states.each do |state|
          proposal = create(:proposal, state: state)
          expect(proposal).to be_finalized
        end
      end
    end

    describe "#finalize" do
      it "changes a soft state to a finalized state" do
        Proposal::SOFT_TO_FINAL.each do |key, val|
          proposal = create(:proposal, state: key)
          proposal.finalize
          expect(proposal.state).to eq(val)
        end
      end

      it "doesn't change a SUBMITTED proposal" do
        proposal = create(:proposal, state: SUBMITTED)
        expect(proposal.finalize).to be_falsey
        expect(proposal.reload.state).to eq(SUBMITTED)
      end
    end

    describe "#update_state" do
      it "updates the state" do
        proposal = create(:proposal, state: ACCEPTED)
        proposal.update_state(WAITLISTED)
        expect(proposal.state).to eq(WAITLISTED)
      end

      it "converts symbolized state before saving" do
        states = {
          soft_rejected: SOFT_REJECTED,
          soft_accepted: SOFT_ACCEPTED,
          soft_waitlisted: SOFT_WAITLISTED,
          soft_withdrawn: SOFT_WITHDRAWN,
          accepted: ACCEPTED
        }

        proposal = create(:proposal)
        states.each do |symbol, string|
          proposal.update_state(symbol)
          expect(proposal.state).to eq(string)
        end
      end
    end
  end

  context "saving tags" do
    RSpec::Matchers.define :match_tags do |expected|
      match do |taggings|
        proposal = taggings.proxy_association.owner
        proposal.save
        proposal.reload
        expect(taggings.reload.map(&:tag)).to match_array(expected)
      end
    end

    let(:proposal) { create(:proposal, title: 't') }

    context "proposal tags" do

      it 'creates taggings from the tags array' do
        proposal.tags = ['one', 'two', 'three']
        expect(proposal.proposal_taggings).to match_tags(['one', 'two', 'three'])
      end

      it 'adds taggings added to the tags array' do
        proposal.tags = ['one', 'two']
        expect(proposal.proposal_taggings).to match_tags(['one', 'two'])

        proposal.tags = ['one', 'two', 'three']
        expect(proposal.proposal_taggings).to match_tags(['one', 'two', 'three'])
      end

      it 'removes taggings removed from the tags array' do
        proposal.tags = ['one', 'two', 'three']
        expect(proposal.proposal_taggings).to match_tags(['one', 'two', 'three'])
        proposal.tags = ['one', 'two']
        expect(proposal.proposal_taggings).to match_tags(['one', 'two'])
      end

      it 'prevents duplicate taggings' do
        proposal.tags = ['one', 'two', 'three', 'one', 'two', 'three']
        expect(proposal.proposal_taggings).to match_tags(['one', 'two', 'three'])
      end
    end

    context "review tags" do

      it 'creates taggings from the review_tags array' do
        proposal.review_tags = ['one', 'two', 'three']
        expect(proposal.review_taggings).to match_tags(['one', 'two', 'three'])
      end

      it 'adds taggings added to the tags array' do
        proposal.review_tags = ['one', 'two']
        expect(proposal.review_taggings).to match_tags(['one', 'two'])
        proposal.review_tags = ['one', 'two', 'three']
        expect(proposal.review_taggings).to match_tags(['one', 'two', 'three'])
      end

      it 'removes taggings removed from the tags array' do
        proposal.review_tags = ['one', 'two', 'three']
        expect(proposal.review_taggings).to match_tags(['one', 'two', 'three'])
        proposal.review_tags = ['one', 'two']
        expect(proposal.review_taggings).to match_tags(['one', 'two'])
      end

      it 'prevents duplicate taggings' do
        proposal.review_tags = ['one', 'two', 'three', 'one', 'two', 'three']
        expect(proposal.review_taggings).to match_tags(['one', 'two', 'three'])
      end
    end
  end

  describe "#save" do
    let(:proposal) { create(:proposal, title: 't') }
    before do
      proposal.tags = ['one', 'two', 'three']
      proposal.review_tags = ['four', 'five', 'six']
      proposal.save
      proposal.reload
    end
    it 'creates proposal_tags' do
      proposal.tags.sort.should == ['one', 'two', 'three'].sort
    end
    it 'creates review_tags' do
      proposal.review_tags.sort.should == ['four', 'five', 'six'].sort
    end
    it "clears proposal_tags if attribute is empty array" do
      proposal.tags = [""] # this is the form param when nothing is checked
      proposal.save
      proposal.reload
      proposal.tags.should == []
    end
    it "clears review_tags if attribute is empty array" do
      proposal.review_tags = [""] # this is the form param when nothing is checked
      proposal.save
      proposal.reload
      proposal.review_tags.should == []
    end
    it "doesn't reset proposal_tags if attribute not set" do
      proposal.tags = nil # this is the form param if not in form at all
      proposal.save
      proposal.reload
      proposal.tags.sort.should == ['one', 'two', 'three'].sort
    end
    it "doesn't reset review_tags if attribute not set" do
      proposal.review_tags = nil # this is the form param if not in form at all
      proposal.save
      proposal.reload
      proposal.review_tags.sort.should == ['four', 'five', 'six'].sort
    end
  end

  describe "#update" do
    let(:proposal) { create(:proposal, title: 't') }
    let(:organizer) { create(:person, :organizer) }

    describe ".last_change" do
      describe "when role organizer" do
        it "is cleared" do
          proposal.update_attributes(title: 'Organizer Edited Title', updating_person: organizer)
          expect(proposal.last_change).to be_nil
        end
      end

      describe "when not role organizer" do
        it "is set to the attributes that were just updated" do
          proposal.update_attributes(title: 'Edited Title')
          expect(proposal.last_change).to eq(["title"])
        end
      end
    end
  end

  describe "#average_rating" do
    let(:proposal) { create(:proposal, title: 'Ratings Test') }

    it "returns an average of all ratings" do
      proposal.ratings.build(score: 2)
      proposal.ratings.build(score: 3)
      proposal.ratings.build(score: 4)
      proposal.ratings.build(score: 5)

      proposal.ratings.size.should == 4
      proposal.average_rating.should == 3.5
    end

    it "returns nil if no rating" do
      proposal.ratings.size.should == 0
      proposal.average_rating.should be_nil
    end
  end

  describe "#standard_deviation" do
    it "calculates standard deviation" do
      values = [
        { scores: [1, 1, 3, 5, 5], result: 1.78885 },
        { scores: [2, 3, 4, 5, 1], result: 1.41421 },
        { scores: [4, 5, 1, 2], result: 1.58113 },
        { scores: [4], result: 0 },
      ]

      values.each do |value|
        proposal = build_stubbed(:proposal)
        value[:scores].each do |i|
          attrs = attributes_for(:rating, score: i)
          proposal.ratings.build(attrs)
        end

        expect(proposal.standard_deviation).to be_within(0.00001).of(value[:result])
      end
    end

    it "returns nil if array is empty" do
      proposal = build_stubbed(:proposal, ratings: [])
      expect(proposal.standard_deviation).to be_nil
    end
  end

  describe "#reviewers" do
    let!(:proposal) { create(:proposal) }
    let!(:reviewer) { create(:person, :reviewer) }
    let!(:organizer) { create(:organizer, event: proposal.event) }

    it "can return the list of reviewers" do
      create(:rating, person: reviewer, proposal: proposal)
      proposal.public_comments.create(attributes_for(:comment, person: organizer))

      expect(proposal.reviewers).to match_array([ reviewer, organizer ])
    end

    it "does not return uninvolved reviewers" do
      expect(proposal.reviewers).to be_empty
    end

    it "does not list a reviewer more than once" do
      create(:rating, person: reviewer, proposal: proposal)
      proposal.public_comments.create(attributes_for(:comment, person: reviewer))

      expect(proposal.reviewers).to match_array([ reviewer ])
    end
  end

  describe "#update_and_send_notifications" do
    it "sends notification to all reviewers" do
      proposal = create(:proposal, title: 'orig_title', pitch: 'orig_pitch')
      reviewer = create(:person, :reviewer)
      organizer = create(:organizer, event: proposal.event)

      create(:rating, person: reviewer, proposal: proposal)
      proposal.public_comments.create(attributes_for(:comment, person: organizer))

      expect {
        proposal.update_and_send_notifications(title: 'new_title', pitch: 'new_pitch')
      }.to change { Notification.count }.by(2)

      expect(reviewer.notifications.count).to eq(1)
      expect(organizer.notifications.count).to eq(1)
      expect(Notification.last.message).to include("title")
      expect(Notification.last.message).to include("pitch")
    end

    it "uses the old title in the notification message" do
      proposal = create(:proposal, title: 'orig_title')
      reviewer = create(:person, :reviewer)
      create(:rating, person: reviewer, proposal: proposal)

      proposal.update_and_send_notifications(title: 'new_title')
      expect(Notification.last.message).to include('orig_title')
    end

    it "doesn't send notification if update is invalid" do
      proposal = create(:proposal)

      expect {
        proposal.update_and_send_notifications(title: '')
      }.to_not change { Notification.count }
    end
  end

  describe "#withdraw" do
    it "sets proposal's state to withdrawn" do
      proposal = create(:proposal, state: SUBMITTED)
      proposal.withdraw

      expect(proposal.state).to eq(WITHDRAWN)
    end

    it "sends a notification to reviewers" do
      proposal = create(:proposal, :with_reviewer_public_comment,
                        state: SUBMITTED)
      expect {
        proposal.withdraw
      }.to change { Notification.count }.by(1)
    end
  end

  context "When propsal has multiple speakers" do
    it "displays the oldest speaker first" do
      proposal = create(:proposal)
      secondary_speaker = create(:speaker, created_at: 2.weeks.ago, proposal: proposal)
      primary_speaker = create(:speaker, created_at: 3.weeks.ago, proposal: proposal)

      expect(proposal.speakers.first).to eq(primary_speaker)
    end
  end

  describe "#to_param" do
    it "returns uuid" do
      proposal = create(:proposal)
      expect(proposal.to_param).to eq(proposal.uuid)
    end
  end

  describe "#has_speaker?" do
    let(:proposal) { create(:proposal) }
    let(:person) { create(:person) }

    it "returns true if person is a speaker on the proposal" do
      create(:speaker, person: person, proposal: proposal)
      expect(proposal).to have_speaker(person)
    end

    it "returns false if person is not a speaker on the proposal" do
      expect(proposal).to_not have_speaker(person)
    end
  end

  describe "#was_rated_by_person?" do
    let(:proposal) { create(:proposal) }
    let(:reviewer) { create(:person, :reviewer) }

    it "returns true if person has rated the proposal" do
      create(:rating, person: reviewer, proposal: proposal)
      expect(proposal.was_rated_by_person?(reviewer)).to be_truthy
    end

    it "returns false if person has not rated the proposal" do
      expect(proposal.was_rated_by_person?(reviewer)).to be_falsey
    end
  end

  describe "#has_reviewer_comments?" do
    let(:proposal) { create(:proposal) }
    let(:reviewer) { create(:person, :reviewer) }

    it "returns true if proposal has reviewer comments" do
      create(:internal_comment, person: reviewer, proposal: proposal)
      expect(proposal).to have_reviewer_comments
    end

    it "returns false if proposal does not have reviewer comments" do
      expect(proposal).to_not have_reviewer_comments
    end
  end
end
