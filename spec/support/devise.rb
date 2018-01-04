RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :request

  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
  end
  config.after { Warden.test_reset! }

end
