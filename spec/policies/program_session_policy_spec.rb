require 'rails_helper'

RSpec.describe ProgramSessionPolicy do
  let(:event) { create(:event) }
  let(:program_team) { create(:program_team, event: event) }
  let(:organizer) { create(:organizer, event: event) }
  let(:program_session) { create(:program_session_with_proposal, event: event) }

  subject { described_class }

  def pundit_user(user)
    CurrentEventContext.new(user, program_session.event)
  end

  permissions :new?, :create?, :edit?, :update?, :update_state?, :promote?, :destroy? do
    it 'denies program_team users' do
      expect(subject).not_to permit(pundit_user(program_team), program_session)
    end

    it 'allows organizer users' do
      expect(subject).to permit(pundit_user(organizer), program_session)
    end
  end

  permissions :show? do
    it 'allows program team users' do
      expect(subject).to permit(pundit_user(program_team), program_session)
    end

    it 'allows organizer users' do
      expect(subject).to permit(pundit_user(organizer), program_session)
    end
  end
end
