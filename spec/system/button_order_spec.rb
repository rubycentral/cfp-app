require 'rails_helper'

# Cancel/Close comes first in DOM order and is grey; the affirmative action comes
# last; the group is right-aligned by its wrapper, never by floating the buttons.
feature 'Cancel and action buttons share one order', type: :system do
  let(:event) { create(:event) }
  let(:organizer_user) { create(:user) }
  let!(:organizer) { create(:teammate, :organizer, user: organizer_user, event: event) }

  before { login_as(organizer_user) }

  def buttons_in(selector)
    page.all("#{selector} .btn", visible: :all)
  end

  def classes_of(buttons)
    buttons.map { |button| button[:class] }.join(' ')
  end

  scenario 'a modal footer lists Cancel then the action as direct children' do
    visit event_staff_schedule_rooms_path(event)

    buttons = buttons_in('#room-new-dialog .modal-footer')
    expect(buttons.map(&:text)).to eq(['Cancel', 'Save'])
    expect(classes_of(buttons)).not_to include('float-end')
    expect(page).not_to have_css('#room-new-dialog .modal-footer .btn-toolbar', visible: :all)
  end

  scenario 'the session format dialog keeps its buttons inside the footer' do
    visit new_event_staff_session_format_path(event)

    expect(buttons_in('.modal-footer').map(&:text)).to eq(['Cancel', 'Save'])
  end

  scenario 'a page form lists Cancel then the action, with Cancel in grey' do
    visit edit_event_staff_guidelines_path(event)

    buttons = buttons_in('.form-submit')
    expect(buttons.map(&:text)).to eq(['Cancel', 'Save Guidelines'])
    expect(buttons.first[:class]).to include('btn-secondary')
    expect(buttons.first[:class]).not_to include('btn-danger')
  end

  scenario 'the event form does not rely on floats for its order' do
    visit edit_event_staff_path(event)

    buttons = buttons_in('.form-submit')
    expect(buttons.map(&:text)).to eq(['Cancel', 'Save'])
    expect(classes_of(buttons)).not_to include('float-end')
  end
end
