require 'rails_helper'

# Pins the computed colours of rules that no screenshot page reaches (error states,
# comment author names, schedule day tabs, email-template chrome), in both themes.
RSpec.describe 'Dark palette', type: :system, js: true do
  FIXTURE = <<~HTML
    <div id="palette-fixture">
      <div class="field_with_errors"><span class="help-block" id="fx-field-error">Required</span></div>
      <div class="has-error"><span class="help-block" id="fx-has-error">Required</span></div>
      <p class="help-block" id="fx-hint">Hint</p>
      <div class="organizer-comment"><div class="message_wrap"><div class="info"><p class="name" id="fx-organizer">Organizer</p></div></div></div>
      <nav class="schedule-nav"><ul><li class="active" id="fx-day-tab">Day 1</li></ul></nav>
      <div class="template-section">
        <p class="notice" id="fx-notice">Notice</p>
        <div class="template-actions"><a class="btn btn-gray" id="fx-btn-gray">Cancel</a></div>
      </div>
      <div class="subnavbar"><div class="dropdown"><div class="dropdown-menu" id="fx-dropdown"></div></div></div>
      <pre><code class="hljs" id="fx-code">x = <span class="hljs-string" id="fx-code-string">'y'</span></code></pre>
    </div>
  HTML

  def computed(id, property, pseudo = nil)
    page.evaluate_script("getComputedStyle(document.getElementById(#{id.inspect}), #{pseudo ? pseudo.inspect : 'null'}).#{property}")
  end

  def visit_with_fixture(theme)
    visit '/404'
    page.execute_script("localStorage.setItem('theme', #{theme.inspect})")
    visit new_session_path
    expect(page).to have_css("html[data-bs-theme=\"#{theme}\"]")
    page.execute_script("document.body.insertAdjacentHTML('beforeend', #{FIXTURE.inspect})")
    expect(page).to have_css('#palette-fixture')
  end

  context 'in light mode' do
    before { visit_with_fixture('light') }

    it 'keeps the colours light mode had before the sweep' do
      expect(computed('fx-has-error', 'color')).to eq('rgb(169, 68, 66)')
      expect(computed('fx-organizer', 'color')).to eq('rgb(145, 24, 28)')
      expect(computed('fx-day-tab', 'color')).to eq('rgb(145, 24, 28)')
      expect(computed('fx-notice', 'color')).to eq('rgb(68, 4, 7)')
      expect(computed('fx-btn-gray', 'backgroundColor')).to eq('rgb(204, 204, 204)')
    end

    it 'gives code blocks the GitHub light theme' do
      expect(computed('fx-code', 'backgroundColor')).to eq('rgb(255, 255, 255)')
      expect(computed('fx-code-string', 'color')).to eq('rgb(3, 47, 98)')
    end
  end

  context 'in dark mode' do
    before { visit_with_fixture('dark') }

    it 'shows form errors in a readable light red' do
      expect(computed('fx-field-error', 'color')).to eq('rgb(241, 174, 181)')
      expect(computed('fx-has-error', 'color')).to eq('rgb(255, 200, 211)')  # the alert danger text, like the alerts
    end

    it 'lightens brand-red text and form hints' do
      expect(computed('fx-organizer', 'color')).to eq('rgb(234, 134, 143)')
      expect(computed('fx-day-tab', 'color')).to eq('rgb(234, 134, 143)')
      expect(computed('fx-notice', 'color')).to eq('rgb(234, 134, 143)')
      expect(computed('fx-hint', 'color')).to eq('rgb(117, 183, 152)')
    end

    it 'darkens the gray button and the subnav dropdown notch' do
      expect(computed('fx-btn-gray', 'backgroundColor')).to eq('rgb(73, 80, 87)')
      expect(computed('fx-dropdown', 'borderBottomColor', '::after')).to eq('rgb(43, 48, 53)')
    end

    it 'gives code blocks a dark surface and the GitHub dark token colours' do
      expect(computed('fx-code', 'backgroundColor')).to eq('rgb(52, 58, 64)')  # --surface-bg-alt
      expect(computed('fx-code', 'color')).to eq('rgb(222, 226, 230)')  # --text-color
      expect(computed('fx-code-string', 'color')).to eq('rgb(165, 214, 255)')
    end
  end
end
