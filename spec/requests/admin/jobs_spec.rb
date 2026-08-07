require 'rails_helper'

RSpec.describe 'Jobs Admin Dashboard', type: :request do
  let(:admin_user) { create(:user, admin: true) }
  let(:non_admin_user) { create(:user) }

  context 'An admin' do
    before { login_as(admin_user) }

    it 'can see the jobs dashboard' do
      get mission_control_jobs_path

      expect(response).to have_http_status(:ok)
    end
  end

  # The redirect targets are spelled out rather than built from route helpers:
  # once a request has gone through the engine, helpers called here inherit its
  # script_name and would themselves expand to /admin/jobs/... -- which is the
  # very mistake these examples exist to catch.
  context 'A non-admin user' do
    before { login_as(non_admin_user) }

    it 'is redirected to the events page' do
      get mission_control_jobs_path

      expect(response).to redirect_to('/events')
    end
  end

  context 'A signed out user' do
    it 'is redirected to the sign in page' do
      get mission_control_jobs_path

      expect(response).to redirect_to('/users/sign_in')
    end
  end
end
