require 'rails_helper'

describe Staff::TimeSlotsController, type: :controller do
  let(:event) { create(:event) }
  before { sign_in(create(:organizer, event: event)) }

  describe "DELETE 'destroy'" do
    it "destroys the time slot" do
      conf_time_slot = create(:time_slot, event: event)
      expect {
        delete :destroy, params: {id: conf_time_slot, event_slug: conf_time_slot.event}, as: :turbo_stream
      }.to change(TimeSlot, :count).by(-1)
    end
  end

  describe "PUT 'update'" do
    it "can update a time slot with turbo_stream" do
      conf_time_slot = create(:time_slot, conference_day: 3, event: event)
      put :update, params: {id: conf_time_slot, event_slug: conf_time_slot.event,
          time_slot: {conference_day: 5}}, as: :turbo_stream
      expect(conf_time_slot.reload.conference_day).to eq(5)
      expect(response).to be_successful
    end

    it "can set the program session" do
      program_session = create(:program_session, event: event)
      conf_time_slot = create(:time_slot, event: program_session.event)
      put :update, params: {id: conf_time_slot, event_slug: conf_time_slot.event,
          time_slot: {program_session_id: program_session.id}}, as: :turbo_stream
      expect(conf_time_slot.reload.program_session).to eq(program_session)
    end
  end
end
