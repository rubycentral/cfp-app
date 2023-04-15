require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CFPApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.view_specs false
      g.helper false
      g.assets false
      g.template_engine :haml
    end

    config.active_record.time_zone_aware_types = [:datetime]

    config.active_job.queue_adapter = :sidekiq
    config.active_record.yaml_column_permitted_classes =
      [Symbol, Hash, Array, ActiveSupport::HashWithIndifferentAccess, ActionController::Parameters]
  end
end
