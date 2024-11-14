require 'support/helpers/session_helpers'
require 'support/helpers/form_helpers'

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
  config.include Features::FormHelpers, type: :feature
end
