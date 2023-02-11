require 'rails_helper'

RSpec.describe PagePolicy do
  let(:event) { create(:event) }
  let(:program_team) { create(:program_team, event: event) }
  let(:organizer) { create(:organizer, event: event) }
  let(:admin) { create(:admin) }

  subject { described_class }

  def pundit_user(user)
    CurrentEventContext.new(user, event)
  end

  permissions(
    :index?,
    :new?,
    :create?,
    :edit?,
    :update?,
    :show?,
    :preview?,
    :publish?,
    :promote?
  )  do
    it 'allows organizers for event' do
      skip "FactoryBot 😤"
      expect(subject).to permit(pundit_user(organizer))
    end

    it 'does not allow program team users' do
      expect(subject).not_to permit(pundit_user(program_team))
    end

    it 'does not allow admin users' do
      expect(subject).not_to permit(pundit_user(admin))
    end
  end
end


