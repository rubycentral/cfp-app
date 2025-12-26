Rails.application.routes.draw do
  root 'home#show'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  mount ActionCable.server => '/cable'

  resource :profile, only: [:show, :edit, :update] do
    get :notifications
    patch :notifications, action: :update_notifications
    get :merge
    post :merge, action: :confirm_merge
  end
  get '/my-proposals' => 'proposals#index', as: :proposals

  resources :notifications, only: [:index, :show] do
    post :mark_all_as_read, on: :collection
  end

  resources :events, param: :slug, only: [:index, :show] do
    resources :proposals, param: :uuid do
      member do
        post :confirm
        post :withdraw
        post :decline
        post :update_notes
      end
      collection do
        post :preview
      end
    end

    #Staff URLS
    namespace 'staff' do
      resource :event, only: [:show, :edit, :update], path: '', as: '' do
        get :info
        get :configuration, path: 'config', as: :config
        patch :update_status, path: 'update-status'
        patch :open_cfp
      end

      resource :custom_fields, only: [:edit, :update]
      resource :reviewer_tags, only: [:edit, :update]
      resource :proposal_tags, only: [:edit, :update]

      resource :guidelines, only: [:show, :edit, :update]

      resources :speaker_email_templates, only: [:index, :show, :edit, :update, :destroy] do
        member do
          post :test
        end
      end

      resources :teammates, path: 'team', only: [:index, :create, :update, :destroy]

      # Reviewer flow for proposals
      resources :proposals, controller: 'proposal_reviews', only: [:index, :show, :update], param: :uuid do
        resources :ratings, only: [:create, :update]
      end

      scope :program, as: 'program' do
        resources :proposals, only: [:index, :show, :update], param: :uuid do
          collection do
            get 'selection'
            get 'session_counts'
            get 'bulk_finalize'
            post 'finalize_by_state'
          end
          member do
            post :finalize
            post :update_state
          end
        end

        resources :speakers, only: [:index, :show, :edit, :update, :destroy]
        resources :program_sessions, as: 'sessions', path: 'sessions' do
          resources :speakers, only: [:new, :create]
          member do
            post :confirm_for_speaker
            patch :promote
          end
        end
      end

      scope :schedule, as: 'schedule' do
        resources :rooms, only: [:index, :create, :update, :destroy]
        resources :time_slots, except: :show
        resource :grid, only: :show do
          resources :time_slots, module: 'grids', only: [:edit, :update]
          resources :program_sessions, module: 'grids', only: [:show]
          resource :bulk_time_slot, module: 'grids', only: [:create] do
            collection do
              get 'new/:day', to: 'bulk_time_slots#new', as: 'new', constraints: { day: /\d+/ }
              get 'cancel/:day', to: 'bulk_time_slots#cancel', as: 'cancel', constraints: { day: /\d+/ }
              post :preview
              post :edit
            end
          end
        end
      end

      resources :session_formats, except: :show
      resources :tracks, except: [:show]
      draw :staff_website  # => config/routes/staff_website.rb
    end
  end
  resources :events, only: [:index]

  resources :public_comments, only: [:create], controller: :comments, type: 'PublicComment'
  resources :internal_comments, only: [:create], controller: :comments, type: 'InternalComment'

  resources :speakers, only: [:destroy]

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

    resources :users, only: [:index, :show, :edit, :update, :destroy]
  end

  draw :website # => config/routes/website.rb

  get '/404', :to => 'errors#not_found', as: :not_found
  get '/422', :to => 'errors#unacceptable'
  get '/500', :to => 'errors#internal_error'
end
