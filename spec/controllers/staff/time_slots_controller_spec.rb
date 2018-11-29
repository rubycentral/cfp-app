require 'rails_helper'

describe Staff::TimeSlotsController, type: :controller do
  let(:event) { create(:event) }
  before { sign_in(create(:organizer, event: event)) }

  describe "DELETE 'destroy'" do
    it "destroys the time slot" do
      conf_time_slot = create(:time_slot, event: event)
      expect {
        delete :destroy, xhr: true, params: {id: conf_time_slot, event_slug: conf_time_slot.event}
      }.to change(TimeSlot, :count).by(-1)
    end
  end

  describe "PUT 'update'" do
    it "can update a time slot with ajax" do
      conf_time_slot = create(:time_slot, conference_day: 3, event: event)
      put :update, xhr: true, params: {id: conf_time_slot, event_slug: conf_time_slot.event,
          time_slot: { conference_day: 5 }}
      expect(assigns(:time_slot).conference_day).to eq(5)
      expect(response).to be_successful
    end

    it "can set the program session" do
      program_session = create(:program_session, event: event)
      conf_time_slot = create(:time_slot, event: program_session.event)
      put :update, xhr: true, params: {id: conf_time_slot, event_slug: conf_time_slot.event,
          time_slot: { program_session_id: program_session.id }}
      expect(assigns(:time_slot).program_session).to eq(program_session)
    end
  end

end
