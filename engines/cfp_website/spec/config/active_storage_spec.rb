require 'rails_helper'

RSpec.describe 'ActiveStorage in the website engine' do
  it 'keeps the 8.1 framework defaults' do
    expect(Rails.application.config.active_storage.variant_processor).to eq(:vips)
  end
end
