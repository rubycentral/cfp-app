Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email'
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :developer unless Rails.env.production?
end

OmniAuth.config.path_prefix = '/users/auth'
OmniAuth.config.allowed_request_methods = [:post]
