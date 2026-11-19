require 'rails_helper'

RSpec.describe 'Notifications', type: :request do
  it 'sends a signed-out visitor to the sign-in page' do
    get notifications_path
    expect(response).to redirect_to(new_session_url)
  end
end
