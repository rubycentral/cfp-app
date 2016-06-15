RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :request

  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
  end
  config.after { Warden.test_reset! }

end
