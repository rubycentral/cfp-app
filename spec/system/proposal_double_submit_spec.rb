require 'rails_helper'

feature 'Proposal submission double-click protection', type: :system, js: true do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, state: 'open') }
  let!(:session_format) { create(:session_format, name: 'Only format') }

  before do
    login_as(user)
    visit new_event_proposal_path(event)

    fill_in 'Title', with: 'Once and only once'
    fill_in 'Abstract', with: 'A talk about idempotent form submissions.'
    fill_in 'proposal_speakers_attributes_0_bio', with: 'I am awesome.'
    fill_in 'Pitch', with: 'Delivered exactly once.'
    fill_in 'Details', with: 'No double submissions.'
    select 'Only format', from: 'Session format'
  end

  scenario 'the submit button is disabled as soon as the form is submitted' do
    # Keep the page around after submit so the button state can be inspected:
    # this listener runs after the disable-submit controller's (registered at
    # connect time), so the disable still happens first.
    page.execute_script(<<~JS)
      document.querySelector('[data-proposal-preview-target="form"]')
        .addEventListener('submit', function(e) { e.preventDefault() })
    JS
    click_button 'Submit'

    expect(page).to have_button('Submit', disabled: true)
    expect(Proposal.count).to eq(0)
  end

  scenario 'a double click creates exactly one proposal' do
    button = find('.form-submit button[type="submit"]')
    button.click
    # The second click of a double-click either hits an already-disabled
    # button or a page mid-navigation; either way one proposal must result.
    begin
      button.click
    rescue StandardError
      # element detached mid-navigation — the first submit won, which is fine
    end

    expect(page).to have_content('Thank you!')
    expect(Proposal.where(title: 'Once and only once').count).to eq(1)
  end
end
