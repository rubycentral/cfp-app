require 'rails_helper'

describe Notification do
  describe ".create_for" do
    let(:users) { create_list(:user, 3) }

    it "creates notification for a list of user" do
      expect {
        users.each do |user|
          Notification.create_for(user)
        end
      }.to change { Notification.count }.by(users.count)
      users.each { |p| expect(p.notifications.size).to eq(1) }
    end

    it "sets the notification's message" do
      message = 'test message'
      users.each do |user|
        Notification.create_for(user, message: message)
      end
      users.each do |p|
        expect(p.notifications.first.message).to eq(message)
      end
    end

    it "sets the target path" do
      target_path = '/test_path'
      users.each do |user|
        Notification.create_for(user, target_path: target_path)
      end
      users.each do |p|
        expect(p.notifications.first.target_path).to eq(target_path)
      end
    end

    it "uses proposal's url if proposal is present" do
      proposal = create(:proposal)
      users.each do |user|
        Notification.create_for(user, proposal: proposal)
      end
      users.each do |p|
        expect(p.decorate.proposal_notification_url(proposal)).to(
          eq(p.notifications.first.target_path))
      end
    end
  end

  describe ".create_for_all" do
    let(:users) { create_list(:user, 3) }
    it "calls `.create_for for each user passed" do
      users.each do |user|
        expect(Notification).to receive(:create_for)
          .exactly(1).times
          .with(user, proposal: "this one")
      end

      described_class.create_for_all(users, proposal: "this one")
    end
  end

  describe ".mark_as_read_for_proposal" do
    let!(:user) { create(:user) }
    let!(:proposal) { create(:proposal) }
    let!(:notification) { create(:notification, :unread, user: user, target_path: "/proposal/#{proposal.id}") }

    it "marks read for proposal" do
      expect(notification.read_at).to be_nil
      Notification.mark_as_read_for_proposal("/proposal/#{proposal.id}")
      notification.reload
      expect(notification.read_at).to_not be_nil
    end
  end

  describe ".more_unread?" do
    let(:user) { create(:user) }

    before :each do
      create_count = Notification::UNREAD_LIMIT + 2
      create_count.times do |i|
        create(:notification, read_at: nil, message: "Notification #{i}", user: user)
      end
    end

    it "tells you there are more than the Notification::UNREAD_LIMIT of #{Notification::UNREAD_LIMIT} notifications for user" do
      expect(user.notifications.more_unread?).to eq(true)
    end
  end

  describe ".more_unread_count" do
    let(:user) { create(:user) }

    before :each do
      create_count = Notification::UNREAD_LIMIT + 2
      create_count.times do |i|
        create(:notification, read_at: nil, message: "Notification #{i}", user: user)
      end
    end

    it "returns count of how many over UNREAD_LIMIT are unread" do
      expect(user.notifications.more_unread_count).to eq(2)
    end
  end

  describe "#mark_as_read" do
    it "sets read_at to DateTime.now" do
      now = DateTime.now
      allow(DateTime).to receive(:now) { now }
      notification = create(:notification)
      notification.mark_as_read
      expect(notification.reload).to be_read
      expect(notification.read_at.to_time.to_s).to eq(now.to_time.to_s)
    end
  end

  describe "#read?" do
    it "returns true for a read notification" do
      notification = create(:notification)
      notification.mark_as_read
      expect(notification).to be_read
    end

    it "returns false for an unread notification" do
      notification = create(:notification, read_at: nil)
      expect(notification).to_not be_read
    end
  end

  describe "#short_message" do
    before :each do
      @notification = create(:notification, :with_long_message)
    end

    it "returns shortened message" do
      expect(@notification.short_message).to eq(@notification.message.truncate(50, omission: "..."))
    end
  end
end
