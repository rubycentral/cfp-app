require 'support/helpers/session_helpers'
require 'support/helpers/form_helpers'

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :system
  config.include Features::FormHelpers, type: :system
end
