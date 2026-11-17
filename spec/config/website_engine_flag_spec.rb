require 'rails_helper'
require 'json'
require 'open3'

# ENABLE_WEBSITE is read while config/application.rb loads, so each value
# needs a fresh boot; this spec boots a `rails runner` per value.
RSpec.describe 'ENABLE_WEBSITE' do
  describe 'CfpApp.website_enabled?' do
    def enabled_with(value)
      original = ENV['ENABLE_WEBSITE']
      ENV['ENABLE_WEBSITE'] = value
      CfpApp.website_enabled?
    ensure
      ENV['ENABLE_WEBSITE'] = original
    end

    it 'is on for 1 or true in any case' do
      expect(%w[1 true TRUE yes]).to all(satisfy {|value| enabled_with(value) })
    end

    it 'is off for 0, false, off, blank or unset' do
      expect(['0', 'false', 'FALSE', 'f', 'off', '', ' ', nil]).to all(satisfy {|value| !enabled_with(value) })
    end
  end

  # Which of CfpWebsite and ActiveStorage are defined after booting with the flag.
  def loaded_with(value)
    env = {'ENABLE_WEBSITE' => value, 'RAILS_ENV' => 'test'}
    out, status = Open3.capture2e(env, 'bin/rails', 'runner', 'puts [defined?(CfpWebsite), defined?(ActiveStorage)].to_json', chdir: Rails.root.to_s)
    raise "rails runner failed:\n#{out}" unless status.success?
    JSON.parse(out.lines.last)
  end

  it 'loads the engine and ActiveStorage when set to 1' do
    # Only installable with the flag on (install_if), so the engine-off CI leg lacks the gems.
    skip "the engine's gems are not installed" unless system({'ENABLE_WEBSITE' => '1'}, 'bundle', 'check', '--dry-run', out: File::NULL, err: File::NULL, chdir: Rails.root.to_s)
    expect(loaded_with('1')).to eq(['constant', 'constant'])
  end

  it 'leaves both off when set to 0 or false' do
    expect(loaded_with('0')).to eq([nil, nil])
    expect(loaded_with('false')).to eq([nil, nil])
  end

  it 'says what to do when the flag appears only after Bundler ran, as from .env' do
    env = {'ENABLE_WEBSITE' => nil, 'RAILS_ENV' => 'test'}
    out, status = Open3.capture2e(env, 'bundle', 'exec', 'ruby', '-e', 'ENV["ENABLE_WEBSITE"] = "1"; require "./config/application"', chdir: Rails.root.to_s)
    expect(status).not_to be_success
    expect(out).to include('ENABLE_WEBSITE is set but the website engine is not in the bundle')
  end
end
