require 'rails_helper'

# The event info bar right-aligns its status column on wide screens and lets it
# fall back to the default (start, i.e. left in LTR) on narrow ones via Bootstrap's text-md-end.
RSpec.describe 'Responsive text alignment', type: :system, js: true do
  let(:event) { create(:event) }
  let(:organizer_user) { create(:user) }
  let!(:organizer) { create(:teammate, :organizer, user: organizer_user, event: event) }

  before { login_as(organizer_user) }

  def status_column_alignment
    page.evaluate_script("getComputedStyle(document.querySelector('.event-info-bar .text-md-end')).textAlign")
  end

  it 'right-aligns the status column on a wide screen and not on a narrow one' do
    visit event_staff_program_speakers_path(event)
    expect(page).to have_css('.event-info-bar .text-md-end')

    page.driver.browser.manage.window.resize_to(1400, 900)
    expect(status_column_alignment).to eq('right')

    page.driver.browser.manage.window.resize_to(600, 900)
    expect(status_column_alignment).to eq('start')
  end
end
