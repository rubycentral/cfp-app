module Features
  module FormHelpers
    def fill_in_tinymce(resource, field, content)
      within_frame("#{resource}_#{field}_ifr") do
        editor = page.find_by_id('tinymce')
        editor.native.send_keys(content)
      end
    end
  end
end
