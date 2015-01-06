require 'rails_helper'

describe Notification do
  describe ".create_for" do
    let(:people) { create_list(:person, 3) }

    it "creates notifications for a list of people" do
      expect {
        Notification.create_for(people)
      }.to change { Notification.count }.by(people.count)
      people.each { |p| expect(p.notifications.size).to eq(1) }
    end

    it "sets the notification's message" do
      message = 'test message'
      Notification.create_for(people, message: message)
      people.each do |p|
        expect(p.notifications.first.message).to eq(message)
      end
    end

    it "sets the target path" do
      target_path = '/test_path'
      Notification.create_for(people, target_path: target_path)
      people.each do |p|
        expect(p.notifications.first.target_path).to eq(target_path)
      end
    end

    it "uses proposal's path if proposal is present" do
      proposal = create(:proposal)
      Notification.create_for(people, proposal: proposal)
      people.each do |p|
        expect(p.notifications.first.target_path).to(
          eq(p.decorate.proposal_path(proposal)))
      end
    end
  end

  describe "#read" do
    it "sets read_at to DateTime.now" do
      now = DateTime.now
      allow(DateTime).to receive(:now) { now }
      notification = create(:notification)
      notification.read
      expect(notification.reload).to be_read
      expect(notification.read_at.to_time.to_s).to eq(now.to_time.to_s)
    end
  end

  describe "#read?" do
    it "returns true for a read notification" do
      notification = create(:notification)
      notification.read
      expect(notification).to be_read
    end

    it "returns false for an unread notification" do
      notification = create(:notification, read_at: nil)
      expect(notification).to_not be_read
    end
  end
end
