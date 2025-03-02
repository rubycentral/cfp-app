require 'devise/version'

if Devise::VERSION < '5'
  ActiveSupport.on_load :action_mailer do
    Rails.application.reload_routes_unless_loaded
  end
else
  raise 'Perhaps this issue has been fixed upstream. Consider removing this monkey-patch for Devise.'
end
