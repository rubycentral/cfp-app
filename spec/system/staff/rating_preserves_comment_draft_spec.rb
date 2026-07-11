require 'rails_helper'

feature 'Rating a proposal with an internal comment draft in progress', type: :system, js: true do
  let(:event) { create(:event, state: 'open') }
  let(:reviewer_user) { create(:user) }
  let(:proposal) { create(:proposal_with_track, event: event) }
  let!(:teammate) { create(:teammate, :reviewer, user: reviewer_user, event: event) }

  before do
    reviewer_user.ratings.create!(proposal: proposal, score: 3)
    login_as(reviewer_user)
    visit event_staff_proposal_path(event, proposal)
  end

  it 'changing the star rating preserves typed internal comment text' do
    fill_in 'internal_comment_body', with: 'Half-typed thought'

    within('#rating-form') do
      find("input[value='5']", visible: false).set(true)
    end
    expect(page).to have_css('.avg-rating', text: '5.0')

    expect(page).to have_field('internal_comment_body', with: 'Half-typed thought')
  end

  it 'removing the rating hides the internal comments again' do
    within('#rating-form') do
      find('input.star-rating-select.delete', visible: false).set(true)
    end

    expect(page).to_not have_content('Internal Comment')
  end
end
