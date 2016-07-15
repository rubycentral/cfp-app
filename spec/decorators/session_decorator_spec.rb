require 'rails_helper'

describe TimeSlotDecorator do
  describe '#row_data' do
    it 'returns a link to the proposal in the title' do
      time_slot = FactoryGirl.create(:time_slot_with_program_session)
      path = h.event_staff_proposal_path(time_slot.event, time_slot.program_session.proposal)
      data = time_slot.decorate.row_data
      expect(data[3]).to match(path)
    end

    it 'returns the title if there is no program session' do
      time_slot = FactoryGirl.create(:time_slot)
      data = time_slot.decorate.row_data
      expect(data[3]).to eq(time_slot.title)
    end
  end
end
