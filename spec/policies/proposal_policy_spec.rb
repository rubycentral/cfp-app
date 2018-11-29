require 'rails_helper'

RSpec.describe ProposalPolicy do
  let(:reviewer) { create(:user, :reviewer) }
  let(:program_team) { create(:user, :program_team) }
  let(:organizer) { create(:organizer) }
  let(:speaker) { create(:speaker) }

  subject { described_class }

  def pundit_user(user)
    CurrentEventContext.new(user, speaker.event)
  end

  permissions :update_track?, :update_session_format? do
    it 'allows program_team users' do
      expect(subject).to permit(pundit_user(program_team), speaker)
    end

    it 'allows organizer users' do
      expect(subject).to permit(pundit_user(organizer), speaker)
    end

    it 'allows reviewer users' do
      expect(subject).to permit(pundit_user(reviewer), speaker)
    end

    it 'denies speaker users' do
      expect(subject).not_to permit(pundit_user(speaker.user), speaker)
    end
  end

  permissions :bulk_finalize? do
    it 'denies program_team users' do
      expect(subject).not_to permit(pundit_user(program_team), speaker)
    end

    it 'allows organizer users' do
      expect(subject).to permit(pundit_user(organizer), speaker)
    end

    it 'denies reviewer users' do
      expect(subject).not_to permit(pundit_user(reviewer), speaker)
    end

    it 'denies speaker users' do
      expect(subject).not_to permit(pundit_user(speaker.user), speaker)
    end
  end
end
