require 'rails_helper'

# JS system specs share one headless Chrome for speed, so whatever an example
# leaves in the browser (web storage, emulated media, the window size) must be
# reset before the next example runs. These two examples rely on their order:
# the first pollutes the browser, the second must find it clean.
RSpec.describe 'Browser isolation between JS examples', type: :system, js: true, order: :defined do
  def prefers_dark?
    page.evaluate_script("matchMedia('(prefers-color-scheme: dark)').matches")
  end

  def emulate_color_scheme(value)
    page.driver.browser.execute_cdp('Emulation.setEmulatedMedia', features: [{name: 'prefers-color-scheme', value: value}])
  end

  it 'leaves state behind in the browser' do
    visit '/404'
    page.execute_script("localStorage.setItem('leak', 'yes'); sessionStorage.setItem('leak', 'yes')")
    page.driver.browser.manage.window.resize_to(600, 900)
    # The machine decides the real colour scheme, so emulate whichever one it is not
    emulate_color_scheme(prefers_dark? ? 'light' : 'dark')

    expect(page.evaluate_script("localStorage.getItem('leak')")).to eq 'yes'
    expect(page.evaluate_script('innerWidth')).to eq 600
  end

  it 'starts the next example with a clean browser' do
    visit '/404'

    expect(page.evaluate_script("localStorage.getItem('leak')")).to be_nil
    expect(page.evaluate_script("sessionStorage.getItem('leak')")).to be_nil

    emulated = prefers_dark?
    emulate_color_scheme('')
    expect(emulated).to eq prefers_dark?

    expect(page.evaluate_script('innerWidth')).to eq 1400
  end
end
