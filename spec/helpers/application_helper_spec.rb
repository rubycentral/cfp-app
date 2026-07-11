require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#markdown' do
    it 'opts explicit links out of Turbo so they escape a surrounding turbo-frame' do
      html = helper.markdown('see [example](https://example.com)')

      expect(html).to include('href="https://example.com"')
      expect(html).to include('data-turbo="false"')
    end

    it 'applies the same attribute to autolinked bare URLs' do
      html = helper.markdown('visit https://example.com now')

      expect(html).to include('data-turbo="false"')
    end
  end
end
