require 'rails_helper'

RSpec.describe 'ActiveStorage in the website engine' do
  it 'keeps the 8.1 framework defaults' do
    expect(Rails.application.config.active_storage.variant_processor).to eq(:vips)
  end

  it 'stores uploads through the Disk service under tmp/storage' do
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new('hi'), filename: 'hi.txt')
    expect(ActiveStorage::Blob.service).to be_a(ActiveStorage::Service::DiskService)
    expect(ActiveStorage::Blob.service.root.to_s).to eq(Rails.root.join('tmp/storage').to_s)
    expect(blob.download).to eq('hi')
  end

  it 'maps every environment to a service' do
    expect(CfpWebsite::STORAGE_SERVICES).to eq('development' => :local, 'test' => :test, 'production' => :amazon)
  end

  it 'serves SVG inline' do
    expect(ActiveStorage.content_types_to_serve_as_binary).not_to include('image/svg+xml')
  end
end
