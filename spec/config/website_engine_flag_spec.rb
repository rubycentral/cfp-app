require 'rails_helper'
require 'open3'

# ENABLE_WEBSITE is read while config/application.rb loads, so each value
# needs a fresh boot; this spec boots a `rails runner` per value.
RSpec.describe 'ENABLE_WEBSITE' do
  def engine_loaded?(value)
    env = {'ENABLE_WEBSITE' => value, 'RAILS_ENV' => 'test'}
    out, status = Open3.capture2e(env, 'bin/rails', 'runner', 'puts defined?(CfpWebsite).inspect', chdir: Rails.root.to_s)
    raise "rails runner failed:\n#{out}" unless status.success?
    out.lines.last.strip == '"constant"'
  end

  it 'loads the engine when set to 1' do
    expect(engine_loaded?('1')).to be true
  end

  it 'leaves the engine off when set to 0 or false' do
    expect(engine_loaded?('0')).to be false
    expect(engine_loaded?('false')).to be false
  end
end
