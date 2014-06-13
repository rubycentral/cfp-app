require 'rails_helper'

describe SessionDecorator do
  describe '#row_data' do
    it 'returns a link to the proposal in the title' do
      session = FactoryGirl.create(:session_with_proposal)
      path = h.organizer_event_proposal_path(session.event, session.proposal)
      data = session.decorate.row_data
      expect(data[3]).to match(path)
    end

    it 'returns the title if there is no proposal' do
      session = FactoryGirl.create(:session)
      data = session.decorate.row_data
      expect(data[3]).to eq(session.title)
    end
  end
end
