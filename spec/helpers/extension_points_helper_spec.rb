require 'rails_helper'

RSpec.describe ExtensionPointsHelper, type: :helper do
  around do |example|
    points = Rails.application.config.x.extension_points
    saved = points[:spec_point].dup
    example.run
  ensure
    points[:spec_point] = saved
  end

  it 'renders nothing when no partial is registered' do
    expect(helper.render_extensions(:spec_point)).to eq('')
  end

  it 'renders registered partials in order with locals' do
    controller.prepend_view_path(Rails.root.join('spec/fixtures/views'))
    Rails.application.config.x.extension_points[:spec_point] << 'extensions/greeting' << 'extensions/greeting'
    expect(helper.render_extensions(:spec_point, name: 'Ruby')).to eq("<p>Hello Ruby</p>\n<p>Hello Ruby</p>\n")
  end
end
