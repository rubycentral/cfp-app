require 'rails_helper'

RSpec.describe 'Custom domain routing', type: :request do
  it 'serves the sponsors page on a configured domain' do
    event = create(:event)
    create(:website, event: event, domains: 'conf.example')
    host! 'conf.example'
    get '/sponsors'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(event.name)
  end
end
