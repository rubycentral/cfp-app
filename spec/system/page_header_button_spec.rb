require 'rails_helper'

# A page header's action button (.btn-nav) must sit inside the header box,
# beside the title, not spill over the header's bottom border.
RSpec.describe 'Page header action button', type: :system, js: true do
  let(:event) { create(:event) }
  let(:admin_user) { create(:user, admin: true) }
  let!(:admin_teammate) { create(:teammate, event: event, user: admin_user, role: 'organizer') }

  before { login_as(admin_user) }

  def rect(selector)
    page.evaluate_script("(r => ({top: r.top, bottom: r.bottom}))(document.querySelector(#{selector.inspect}).getBoundingClientRect())")
  end

  it 'keeps the button within the header box on the events admin page' do
    visit admin_events_path
    expect(page).to have_link('Add an Event')

    header = rect('.page-header')
    button = rect('.page-header .btn-nav .btn')

    expect(button['top']).to be >= header['top']
    expect(button['bottom']).to be <= header['bottom']
  end
end
