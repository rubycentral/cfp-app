require 'rails_helper'

RSpec.describe 'GET /current-styleguide', type: :request do
  it 'renders the styleguide from its own controller' do
    get current_styleguide_path
    expect(response).to have_http_status(:ok)
    expect(controller).to be_a(StyleguideController)
  end
end
