require 'rails_helper'
require 'open3'

# ENABLE_WEBSITE is read while config/application.rb loads, so each value
# needs a fresh boot; this spec boots a `rails runner` per value.
RSpec.describe 'ENABLE_WEBSITE' do
  # Which of CfpWebsite and ActiveStorage are defined after booting with the flag.
  def loaded_with(value)
    env = {'ENABLE_WEBSITE' => value, 'RAILS_ENV' => 'test'}
    out, status = Open3.capture2e(env, 'bin/rails', 'runner', 'puts [defined?(CfpWebsite), defined?(ActiveStorage)].inspect', chdir: Rails.root.to_s)
    raise "rails runner failed:\n#{out}" unless status.success?
    eval(out.lines.last) # rubocop:disable Security/Eval -- our own runner's output
  end

  it 'loads the engine and ActiveStorage when set to 1' do
    expect(loaded_with('1')).to eq(['constant', 'constant'])
  end

  it 'leaves both off when set to 0 or false' do
    expect(loaded_with('0')).to eq([nil, nil])
    expect(loaded_with('false')).to eq([nil, nil])
  end
end
