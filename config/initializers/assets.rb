# Be sure to restart your server when you modify this file.

# Note: node_modules is NOT added to asset paths.
# JS is bundled by esbuild (jsbundling-rails) to app/assets/builds/
# CSS is bundled by postcss (cssbundling-rails) to app/assets/builds/

# Exclude rails-ujs from actionview since we use Turbo instead
# Exclude chartkick gem assets since we bundle it via esbuild
Rails.application.config.after_initialize do
  Rails.application.config.assets.paths.reject! { |p| p.to_s.include?('actionview') || p.to_s.include?('chartkick') }
end
