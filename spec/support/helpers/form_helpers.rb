module Features
  module FormHelpers
    def fill_in_tinymce(resource, field, content)
      iframe_id = "#{resource}_#{field}_ifr"
      within_frame(iframe_id) do
        editor = page.find_by_id('tinymce')
        editor.native.send_keys(content)
      end if page.has_css?("##{iframe_id}")
    end
  end
end
