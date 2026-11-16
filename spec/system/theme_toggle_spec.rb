require 'rails_helper'

RSpec.describe 'Theme toggle', type: :system, js: true do
  def theme_attribute
    page.evaluate_script('document.documentElement.dataset.bsTheme')
  end

  def stored_theme
    page.evaluate_script("localStorage.getItem('theme')")
  end

  def emulate_os_scheme(value)
    page.driver.browser.execute_cdp('Emulation.setEmulatedMedia', features: [{name: 'prefers-color-scheme', value: value}])
  end

  def toggle
    find('button.theme-toggle')
  end

  # The icon is an empty <i> drawn by the icon font, which Capybara doesn't count as visible
  def expect_icon(name)
    expect(page).to have_css("button.theme-toggle i.bi.#{name}", visible: :all)
  end

  before do
    visit '/404'
    emulate_os_scheme('light')
  end

  it 'shows the toggle to a signed-out visitor and starts in auto' do
    visit new_session_path
    expect(page).to have_css('button.theme-toggle[title="Theme: auto (click for light)"]')
    expect_icon('bi-circle-half')
    expect(theme_attribute).to eq('light')
    expect(stored_theme).to be_nil
  end

  it 'cycles auto → light → dark → auto and stores the preference' do
    visit root_path
    toggle.click
    expect(page).to have_css('button.theme-toggle[title="Theme: light (click for dark)"]')
    expect_icon('bi-sun-fill')
    expect(theme_attribute).to eq('light')
    expect(stored_theme).to eq('light')

    toggle.click
    expect(page).to have_css('button.theme-toggle[title="Theme: dark (click for auto)"]')
    expect_icon('bi-moon-stars-fill')
    expect(theme_attribute).to eq('dark')
    expect(stored_theme).to eq('dark')

    toggle.click
    expect(page).to have_css('button.theme-toggle[title="Theme: auto (click for light)"]')
    expect(stored_theme).to eq('auto')
    expect(theme_attribute).to eq('light')
  end

  it 'applies the stored theme on a full reload and across a Turbo frame navigation' do
    user = create(:organizer)
    login_as user
    visit root_path
    toggle.click
    toggle.click
    expect(theme_attribute).to eq('dark')

    visit config_event_staff_path(user.organizer_events.first)
    expect(theme_attribute).to eq('dark')

    find('turbo-frame#custom-fields a.add-custom-fields, turbo-frame#custom-fields a.edit-custom-fields').click
    expect(page).to have_css('turbo-frame#custom-fields form')
    expect(theme_attribute).to eq('dark')
  end

  it 'treats an unknown stored value as auto' do
    visit root_path
    page.execute_script("localStorage.setItem('theme', 'blue')")
    visit root_path
    expect(theme_attribute).to eq('light')
    expect(page).to have_css('button.theme-toggle[title="Theme: auto (click for light)"]')
  end

  it 'follows the OS scheme while in auto' do
    visit root_path
    expect(page).to have_css('html[data-bs-theme="light"]')
    emulate_os_scheme('dark')
    expect(page).to have_css('html[data-bs-theme="dark"]')
    emulate_os_scheme('light')
    expect(page).to have_css('html[data-bs-theme="light"]')
  end

  it 'still renders and toggles when localStorage throws' do
    visit root_path
    page.execute_script("Object.defineProperty(window, 'localStorage', {get() { throw new Error('blocked') }})")
    toggle.click
    expect(theme_attribute).to eq('light')
    toggle.click
    expect(theme_attribute).to eq('dark')
  end

  it 'retunes Chart.js defaults to the active theme' do
    visit root_path
    chart_color = -> { page.evaluate_script('window.Chartkick.adapters[0].library.defaults.color') }
    expect(chart_color.call).to eq('#666')  # Chart.js's own default, untouched in light mode

    toggle.click
    toggle.click
    expect(theme_attribute).to eq('dark')
    expect(chart_color.call).to eq('#dee2e6')

    toggle.click
    expect(theme_attribute).to eq('light')
    expect(chart_color.call).to eq('#666')
  end

  it 'keeps flash alerts visible in dark mode' do
    visit root_path
    page.execute_script("localStorage.setItem('theme', 'dark')")
    visit new_session_path
    fill_in 'Email', with: 'nobody@example.com'
    fill_in 'Password', with: 'wrong'
    click_button 'Log in'
    expect(page).to have_css('html[data-bs-theme="dark"]')
    expect(page).to have_css('#flash .alert.alert-danger', text: 'Invalid Email or password.', visible: true)
  end
end
