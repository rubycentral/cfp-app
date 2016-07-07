# require 'rails_helper'
#
# describe Staff::TeamInvitationsController, type: :controller do
#   let(:event) { create(:event) }
#   let(:organizer) { create(:organizer, event: event) }
#   before { sign_in(organizer) }
#
#   describe "POST #create" do
#     let(:valid_params) do
#       {
#         event_slug: event.slug,
#         event_teammate_invitation: attributes_for(:event_teammate_invitation)
#       }
#     end
#
#     it "creates a event_teammate invitation" do
#       expect {
#         post :create, valid_params
#       }.to change { EventTeammateInvitation.count }.by(1)
#     end
#
#     it "sends an invitation email" do
#       expect {
#         post :create, valid_params
#       }.to change { ActionMailer::Base.deliveries.count }.by(1)
#     end
#   end
# end
