CFPApp::Application.routes.draw do

  resources :notifications, only: [ :index, :show ] do
    post :mark_all_as_read, on: :collection
  end

  root 'home#show'

  match '/auth/:provider/callback' => 'sessions#create', via: [:get, :post]
  get '/auth/failure' => 'sessions#new', error: true
  get '/signout' => 'sessions#destroy', as: :signout
  resource :session, only: [:new, :create, :destroy]

  resource :profile, only: [:edit, :update]
  resource :public_comments, only: [:create], controller: :comments, type: 'PublicComment'
  resource :internal_comments, only: [:create], controller: :comments, type: 'InternalComment'
  resources :speakers, only: [:destroy]
  resources :proposals, only: [:index]
  resources :events, only: [:index]
  scope '/events/:slug' do
    get '/' => 'events#show', as: :event

    post '/proposals' => 'proposals#create', as: :event_proposals
    get 'parse_edit_field' => 'proposals#parse_edit_field',
      as: :parse_edit_field_proposal

    resources :proposals, param: :uuid do
      member { get :confirm }
      member { post :set_confirmed }
      member { post :withdraw }
      member { delete :destroy}
    end
  end

  resources :participant_invitations, only: :show, param: :slug do
    member do
      get ":token/accept", action: :accept, as: :accept
      get ":token/refuse", action: :refuse, as: :refuse
    end
  end

	resources :invitations, only: [:show, :create, :destroy], param: :invitation_slug do
		member do
			post :accept, action: :update
			post :refuse, action: :update, refuse: true
			post :resend, action: :resend
		end
	end

  namespace 'admin' do
    resources :events, except: [:show, :edit, :update] do
      post :archive
      post :unarchive
    end

    resources :people
  end

  namespace 'organizer' do
    resources :events, only: [:edit, :show, :update] do
      resources :participant_invitations, except: [ :new, :edit, :update, :show ]

      controller :program do
        get 'program' => 'program#show'
      end

      resources :participants, only: [:create, :destroy, :update] do
        collection { get :emails, defaults: { format: :json } }
      end

      resources :rooms, only: [:create, :update, :destroy]
      resources :tracks, only: [:create, :destroy]
      resources :sessions, except: :show
      resources :proposals, param: :uuid do
        resources :speakers, only: [:new, :create]
        post :finalize
        post :update_state
      end

      controller :speakers do
        get :speaker_emails, action: :emails
      end
      resources :speakers, only: [:index, :show, :edit, :update, :destroy] do
        member do
          get :profile, to: "profiles#edit", as: :edit_profile
          patch :profile, to: "profiles#update", as: :update_profile
        end
      end
    end

  end

  namespace 'reviewer' do
    resources :events, only: [] do
      resources :proposals, only: [:index, :show, :update], param: :uuid do
        resources :ratings, only: [:create, :update], defaults: { format: :js }
      end
    end
  end

  get "/404", :to => "errors#not_found"
  get "/422", :to => "errors#unacceptable"
  get "/500", :to => "errors#internal_error"

end
