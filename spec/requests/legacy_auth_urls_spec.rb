require 'rails_helper'

RSpec.describe 'Legacy Devise-era URLs', type: :request do
  it 'redirects the old sign-in URL' do
    get '/users/sign_in'
    expect(response).to redirect_to('/session/new')
  end

  it 'redirects the old sign-up URL' do
    get '/users/sign_up'
    expect(response).to redirect_to('/registration/new')
  end

  it 'redirects the old resend-confirmation URL' do
    get '/users/confirmation/new'
    expect(response).to redirect_to('/confirmations/new')
  end

  it 'still confirms via the emailed URL shape sent before this deploy' do
    user = build(:user, email: 'legacy@person.com')
    user.save!

    get "/users/confirmation?confirmation_token=#{CGI.escape(user.email_confirmation_token)}"

    expect(user.reload.confirmed?).to be true
  end

  it 'still signs out via the old sign-out URL' do
    delete '/users/sign_out'
    expect(response).to redirect_to(root_path)
  end
end
