require 'rails_helper'

describe Staff::TimeSlotDecorator do
  describe '#row_data' do
    it 'returns a link to the proposal in the title' do
      time_slot = FactoryBot.create(:time_slot_with_program_session)
      path = h.event_staff_program_session_path(time_slot.event, time_slot.program_session)
      data = Staff::TimeSlotDecorator.decorate(time_slot).row_data
      expect(data[3]).to match(path)
    end

    it 'returns the title if there is no program session' do
      time_slot = FactoryBot.create(:time_slot)
      data = Staff::TimeSlotDecorator.decorate(time_slot).row_data
      expect(data[3]).to eq(time_slot.title)
    end
  end
end
