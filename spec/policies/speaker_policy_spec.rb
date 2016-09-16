require 'rails_helper'

RSpec.describe SpeakerPolicy do

  let(:program_team) { create(:user, :program_team) }
  let(:organizer) { create(:user, :organizer) }
  let(:speaker) { create(:speaker) }

  subject { described_class }

  def pundit_user(user)
    CurrentEventContext.new(user, speaker.event)
  end

  permissions :new?, :create?, :edit?, :update?, :destroy? do

    it 'denies program_team users' do
      expect(subject).not_to permit(pundit_user(program_team), speaker)
    end

    it 'allows organizer users' do
      expect(subject).to permit(pundit_user(organizer), speaker)
    end
  end

end