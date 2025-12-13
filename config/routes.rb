Rails.application.routes.draw do
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

  root 'home#show'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  mount ActionCable.server => '/cable'

  resource :profile, only: [:edit, :update]
  get '/my-proposals' => 'proposals#index', as: :proposals

  resources :notifications, only: [:index, :show] do
    post :mark_all_as_read, on: :collection
  end

  resources :events, param: :slug do
    get '/' => 'events#show', as: :event

    resources :proposals, param: :uuid do
      member { post :confirm }
      member { post :withdraw }
      member { post :decline }
      member { post :update_notes }
      member { delete :destroy }
      collection { post :preview }
    end

    #Staff URLS
    namespace 'staff' do
      get '/' => 'events#show'
      get :show

      get :info
      get :edit
      patch :update
      patch 'update-status' => 'events#update_status'
      patch :open_cfp

      get '/config' => 'events#configuration', as: :config
      resource :custom_fields, only: [:edit, :update]
      resource :reviewer_tags, only: [:edit, :update]
      resource :proposal_tags, only: [:edit, :update]

      resource :guidelines, only: [:show, :edit, :update]

      resources :speaker_email_templates, only: [:index, :show, :edit, :update, :destroy] do
        member do
          post :test
        end
      end

      resources :teammates, path: 'team'

      # Reviewer flow for proposals
      resources :proposals, controller: 'proposal_reviews', only: [:index, :show, :update], param: :uuid do
        resources :ratings, only: [:create, :update]
      end

      scope :program, as: 'program' do
        resources :proposals, param: :uuid do
          collection do
            get 'selection'
            get 'session_counts'
            get 'bulk_finalize'
            post 'finalize_by_state'
          end
          post :finalize
          post :update_state
        end

        resources :speakers, only: [:index, :show, :edit, :update, :destroy]
        resources :program_sessions, as: 'sessions', path: 'sessions' do
          resources :speakers, only: [:new, :create]
          post :update_state
          member do
            post :confirm_for_speaker
            patch :promote
          end
        end
      end

      scope :schedule, as: 'schedule' do
        resources :rooms, only: [:index, :create, :update, :destroy]
        resources :time_slots, except: :show
        resource :grid do
          resources :time_slots, module: 'grids', only: [:new, :create, :edit, :update]
          resources :program_sessions, module: 'grids', only: [:show]
          resource :bulk_time_slot, module: 'grids', only: [] do
            collection do
              get 'new/:day', to: 'bulk_time_slots#new', as: 'new', constraints: { day: /\d+/ }
              get 'cancel/:day', to: 'bulk_time_slots#cancel', as: 'cancel', constraints: { day: /\d+/ }
              post :preview
              post :edit
              post :create
            end
          end
        end
      end

      resources :session_formats, except: :show
      resources :tracks, except: [:show]
      resource :website, only: [:new, :create, :edit, :update] do
        member do
          post :purge
        end
      end
      resources :pages do
        member do
          get :preview
          post :show
          patch :publish
          patch :promote
        end
      end
      resources :sponsors, only: [:index, :new, :create, :edit, :update, :destroy]
    end
  end

  resources :image_uploads, only: :create
  resource :public_comments, only: [:create], controller: :comments, type: 'PublicComment'
  resource :internal_comments, only: [:create], controller: :comments, type: 'InternalComment'

  resources :speakers, only: [:destroy]
  resources :events, only: [:index]

  get 'teammates/:token/accept', :to => 'teammates#accept', as: :accept_teammate
  get 'teammates/:token/decline', :to => 'teammates#decline', as: :decline_teammate

  resources :invitations, only: [:show, :create, :destroy], param: :invitation_slug do
    member do
      get :accept
      get :decline
      get :resend
    end
  end

  namespace 'admin' do
    resources :events, except: [:show, :edit, :update], param: :slug do
      post :archive
      post :unarchive
    end

    resources :users
  end

  get '/current-styleguide', :to => 'pages#current_styleguide'
  get '/404', :to => 'errors#not_found', as: :not_found
  get '/422', :to => 'errors#unacceptable'
  get '/500', :to => 'errors#internal_error'

  get '/(:slug)', to: 'pages#show', as: :landing
  get '/(:slug)/program', to: 'programs#show', as: :program
  get '/(:slug)/schedule', to: 'schedule#show', as: :schedule
  get '/(:slug)/sponsors', to: 'sponsors#show', as: :sponsors
  get '/(:slug)/:page', to: 'pages#show', as: :page
end
