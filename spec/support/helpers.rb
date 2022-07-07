require 'support/helpers/session_helpers'
require 'support/helpers/form_helpers'
require 'support/helpers/domain_helpers'

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
  config.include Features::FormHelpers, type: :feature
  config.include Features::DomainHelpers, type: :feature
end
