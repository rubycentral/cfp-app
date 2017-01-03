require 'rails_helper'

describe EventsController, type: :controller do
  describe 'GET #index' do
    it 'should succeed' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    let(:proposal) { build(:proposal) }
    let(:event) { create(:event, proposals: [proposal]) }

    it 'should succeed' do
      get :show, params: {event_slug: event.slug}
      expect(response.status).to eq(200)
    end
  end

end
