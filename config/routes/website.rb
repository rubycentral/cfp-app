# Website-related routes (beta feature)
# These routes are kept separate as the website feature is incomplete

unless ENV['DISABLE_WEBSITE']
  constraints DomainConstraint.new do
    get '/', to: 'pages#show'
    get '/(:slug)/program', to: 'programs#show'
    get '/(:slug)/schedule', to: 'schedule#show'
    get '/(:slug)/sponsors', to: 'sponsors#show'
    get '/(:slug)/banner_ads', to: 'sponsors#banner_ads'
    get '/(:slug)/sponsors_footer', to: 'sponsors#sponsors_footer'
    get '/:domain_page_or_slug', to: 'pages#show'
    get '/:slug/:page', to: 'pages#show'
  end
end

get '/current-styleguide', :to => 'pages#current_styleguide'

get '/(:slug)', to: 'pages#show', as: :landing
get '/(:slug)/program', to: 'programs#show', as: :program
get '/(:slug)/schedule', to: 'schedule#show', as: :schedule
get '/(:slug)/sponsors', to: 'sponsors#show', as: :sponsors
get '/(:slug)/:page', to: 'pages#show', as: :page
