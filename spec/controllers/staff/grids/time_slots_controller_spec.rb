require 'rails_helper'

describe Staff::Grids::TimeSlotsController, type: :controller do
  let(:event) { create(:event) }
  let(:proposal) { create(:proposal_with_track) }
  before { sign_in(create(:organizer, event: event)) }

  describe "PUT 'update'" do
    it "can update a time slot with ajax" do
      skip "FactoryBot 😤"
      conf_time_slot = create(:time_slot, conference_day: 3, event: event)
      put :update, xhr: true, params: {id: conf_time_slot, event_slug: conf_time_slot.event,
          time_slot: { conference_day: 5 }}, format: :json
      # expect(assigns(:time_slot).conference_day).to eq(5)
      expect(response).to be_successful
      conf_time_slot.reload
      expect(conf_time_slot.conference_day).to eq(5)
    end

    it "can set the program session" do
      skip "FactoryBot 😤"
      program_session = create(:program_session, event: event, proposal: proposal, track: proposal.track)
      conf_time_slot = create(:time_slot, event: program_session.event)
      put :update, xhr: true, params: {id: conf_time_slot, event_slug: conf_time_slot.event,
          time_slot: { program_session_id: program_session.id }}, format: :json
      # expect(assigns(:time_slot).program_session).to eq(program_session)
      conf_time_slot.reload
      expect(conf_time_slot.program_session).to eq(program_session)
    end

    it "rescues errors" do
      skip("Redirect instead of a 500, so we need to auth")
      program_session = create(:program_session, event: event, proposal: proposal, track: proposal.track)
      conf_time_slot = create(:time_slot, event: program_session.event)

      allow_any_instance_of(TimeSlot).to receive(:update) { raise ArgumentError, "BOOM!" }

      put :update, xhr: true, params: {id: conf_time_slot, event_slug: conf_time_slot.event, time_slot: { program_session_id: "A" }}, format: :json

      expect(response).to have_http_status(500)
      expect(JSON.parse(response.body)["errors"]).to eq(["There was a problem updating this time slot."])
    end
  end
end
