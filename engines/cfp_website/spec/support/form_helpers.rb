# rails_helper requires every engine's spec/support; these helpers are only
# meaningful (and only used) when the engine is loaded.
return unless defined?(CfpWebsite)

module Features
  module FormHelpers
    def fill_in_tinymce(resource, field, content)
      iframe_id = "#{resource}_#{field}_ifr"
      within_frame(iframe_id) do
        editor = page.find_by_id('tinymce')
        editor.native.send_keys(content)
      end if page.has_css?("##{iframe_id}")
    end

    def fill_in_codemirror(text)
      within ".CodeMirror" do
        current_scope.click
        field = current_scope.find("textarea", visible: false)
        field.send_keys text
      end
    end

    def computed_style(selector, prop, pseudo: nil)
      page.evaluate_script(<<~SCRIPT
        window.getComputedStyle(document.querySelector('#{selector}'), '#{pseudo}')
              .getPropertyValue('#{prop}')
        SCRIPT
      )
    end
  end
end

RSpec.configure do |config|
  config.include Features::FormHelpers, type: :system
end
