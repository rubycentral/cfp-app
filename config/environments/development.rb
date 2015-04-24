CFPApp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.default_options = {from: 'cfp@example.org'}

  ENV['GITHUB_KEY'] = "e5662bfcd64133b4d7d2";
  ENV['GITHUB_SECRET'] = "f48593fce92c10867cc8aaae0acb700eb7351ee7";

  ENV['TWITTER_KEY'] = "A993PtIUR5Eyi16QS4hZevkQf";
  ENV['TWITTER_SECRET'] = "Y7C4OfweE7PO9Lgz3Iq5lN3hNv0vrJZh8tx2QBm1ClIOOkv67U";

  I18n.enforce_available_locales = false
end
