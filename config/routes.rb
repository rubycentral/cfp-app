# == Route Map (Updated 2014-03-19 09:47)
#
#                                Prefix Verb     URI Pattern                                                                 Controller#Action
#                         notifications GET      /notifications(.:format)                                                    notifications#index
#                          notification GET      /notifications/:id(.:format)                                                notifications#show
#                                  root GET      /                                                                           home#show
#                                       GET|POST /auth/:provider/callback(.:format)                                          sessions#create
#                          auth_failure GET      /auth/failure(.:format)                                                     sessions#new {:error=>true}
#                               signout GET      /signout(.:format)                                                          sessions#destroy
#                               session POST     /session(.:format)                                                          sessions#create
#                           new_session GET      /session/new(.:format)                                                      sessions#new
#                                       DELETE   /session(.:format)                                                          sessions#destroy
#                          edit_profile GET      /profile/edit(.:format)                                                     profiles#edit
#                               profile PATCH    /profile(.:format)                                                          profiles#update
#                                       PUT      /profile(.:format)                                                          profiles#update
#                       public_comments POST     /public_comments(.:format)                                                  comments#create {:type=>"PublicComment"}
#                     internal_comments POST     /internal_comments(.:format)                                                comments#create {:type=>"InternalComment"}
#                               speaker DELETE   /speakers/:id(.:format)                                                     speakers#destroy
#                             proposals GET      /proposals(.:format)                                                        proposals#index
#                                events GET      /events(.:format)                                                           events#index
#                                 event GET      /events/:slug(.:format)                                                     events#show
#                       event_proposals POST     /events/:slug/proposals(.:format)                                           proposals#create
#             parse_edit_field_proposal GET      /events/:slug/parse_edit_field(.:format)                                    proposals#parse_edit_field
#                      confirm_proposal GET      /events/:slug/proposals/:uuid/confirm(.:format)                             proposals#confirm
#                set_confirmed_proposal POST     /events/:slug/proposals/:uuid/set_confirmed(.:format)                       proposals#set_confirmed
#                     withdraw_proposal POST     /events/:slug/proposals/:uuid/withdraw(.:format)                            proposals#withdraw
#                              proposal DELETE   /events/:slug/proposals/:uuid(.:format)                                     proposals#destroy
#                                       GET      /events/:slug/proposals(.:format)                                           proposals#index
#                                       POST     /events/:slug/proposals(.:format)                                           proposals#create
#                          new_proposal GET      /events/:slug/proposals/new(.:format)                                       proposals#new
#                         edit_proposal GET      /events/:slug/proposals/:uuid/edit(.:format)                                proposals#edit
#                                       GET      /events/:slug/proposals/:uuid(.:format)                                     proposals#show
#                                       PATCH    /events/:slug/proposals/:uuid(.:format)                                     proposals#update
#                                       PUT      /events/:slug/proposals/:uuid(.:format)                                     proposals#update
#                                       DELETE   /events/:slug/proposals/:uuid(.:format)                                     proposals#destroy
#                     accept_invitation POST     /invitations/:invitation_slug/accept(.:format)                              invitations#update
#                     refuse_invitation POST     /invitations/:invitation_slug/refuse(.:format)                              invitations#update {:refuse=>true}
#                     resend_invitation POST     /invitations/:invitation_slug/resend(.:format)                              invitations#resend
#                           invitations POST     /invitations(.:format)                                                      invitations#create
#                            invitation GET      /invitations/:invitation_slug(.:format)                                     invitations#show
#                                       DELETE   /invitations/:invitation_slug(.:format)                                     invitations#destroy
#                          admin_events POST     /admin/events(.:format)                                                     admin/events#create
#                       new_admin_event GET      /admin/events/new(.:format)                                                 admin/events#new
#                           admin_event DELETE   /admin/events/:id(.:format)                                                 admin/events#destroy
#                          admin_people GET      /admin/people(.:format)                                                     admin/people#index
#                                       POST     /admin/people(.:format)                                                     admin/people#create
#                      new_admin_person GET      /admin/people/new(.:format)                                                 admin/people#new
#                     edit_admin_person GET      /admin/people/:id/edit(.:format)                                            admin/people#edit
#                          admin_person GET      /admin/people/:id(.:format)                                                 admin/people#show
#                                       PATCH    /admin/people/:id(.:format)                                                 admin/people#update
#                                       PUT      /admin/people/:id(.:format)                                                 admin/people#update
#                                       DELETE   /admin/people/:id(.:format)                                                 admin/people#destroy
#               organizer_event_program GET      /organizer/events/:event_id/program(.:format)                               organizer/program#show
#          organizer_event_participants POST     /organizer/events/:event_id/participants(.:format)                          organizer/participants#create
#           organizer_event_participant PATCH    /organizer/events/:event_id/participants/:id(.:format)                      organizer/participants#update
#                                       PUT      /organizer/events/:event_id/participants/:id(.:format)                      organizer/participants#update
#                                       DELETE   /organizer/events/:event_id/participants/:id(.:format)                      organizer/participants#destroy
#     organizer_event_proposal_finalize POST     /organizer/events/:event_id/proposals/:proposal_uuid/finalize(.:format)     organizer/proposals#finalize
#       organizer_event_proposal_accept POST     /organizer/events/:event_id/proposals/:proposal_uuid/accept(.:format)       organizer/proposals#accept
#       organizer_event_proposal_reject POST     /organizer/events/:event_id/proposals/:proposal_uuid/reject(.:format)       organizer/proposals#reject
#     organizer_event_proposal_waitlist POST     /organizer/events/:event_id/proposals/:proposal_uuid/waitlist(.:format)     organizer/proposals#waitlist
# organizer_event_proposal_update_state POST     /organizer/events/:event_id/proposals/:proposal_uuid/update_state(.:format) organizer/proposals#update_state
#             organizer_event_proposals GET      /organizer/events/:event_id/proposals(.:format)                             organizer/proposals#index
#         edit_organizer_event_proposal GET      /organizer/events/:event_id/proposals/:uuid/edit(.:format)                  organizer/proposals#edit
#              organizer_event_proposal GET      /organizer/events/:event_id/proposals/:uuid(.:format)                       organizer/proposals#show
#                                       PATCH    /organizer/events/:event_id/proposals/:uuid(.:format)                       organizer/proposals#update
#                                       PUT      /organizer/events/:event_id/proposals/:uuid(.:format)                       organizer/proposals#update
#                                       DELETE   /organizer/events/:event_id/proposals/:uuid(.:format)                       organizer/proposals#destroy
#        organizer_event_speaker_emails GET      /organizer/events/:event_id/speaker_emails(.:format)                        organizer/speakers#emails
#              organizer_event_speakers GET      /organizer/events/:event_id/speakers(.:format)                              organizer/speakers#index
#               organizer_event_speaker GET      /organizer/events/:event_id/speakers/:id(.:format)                          organizer/speakers#show
#                  edit_organizer_event GET      /organizer/events/:id/edit(.:format)                                        organizer/events#edit
#                       organizer_event GET      /organizer/events/:id(.:format)                                             organizer/events#show
#                                       PATCH    /organizer/events/:id(.:format)                                             organizer/events#update
#                                       PUT      /organizer/events/:id(.:format)                                             organizer/events#update
#          organizer_autocomplete_email GET      /organizer/autocomplete_email(.:format)                                     organizer/participants#emails {:format=>:json}
#       reviewer_event_proposal_ratings POST     /reviewer/events/:event_id/proposals/:proposal_uuid/ratings(.:format)       reviewer/ratings#create {:format=>:js}
#        reviewer_event_proposal_rating PATCH    /reviewer/events/:event_id/proposals/:proposal_uuid/ratings/:id(.:format)   reviewer/ratings#update {:format=>:js}
#                                       PUT      /reviewer/events/:event_id/proposals/:proposal_uuid/ratings/:id(.:format)   reviewer/ratings#update {:format=>:js}
#              reviewer_event_proposals GET      /reviewer/events/:event_id/proposals(.:format)                              reviewer/proposals#index
#               reviewer_event_proposal GET      /reviewer/events/:event_id/proposals/:uuid(.:format)                        reviewer/proposals#show
#                                       PATCH    /reviewer/events/:event_id/proposals/:uuid(.:format)                        reviewer/proposals#update
#                                       PUT      /reviewer/events/:event_id/proposals/:uuid(.:format)                        reviewer/proposals#update
#                                       GET      /404(.:format)                                                              errors#not_found
#                                       GET      /422(.:format)                                                              errors#unacceptable
#                                       GET      /500(.:format)                                                              errors#internal_error
#

CFPApp::Application.routes.draw do

  resources :notifications, only: [ :index, :show ]

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
    resources :events, except: [:show, :index, :edit, :update]
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
        post :finalize
        post :update_state
      end

      controller :speakers do
        get :speaker_emails, action: :emails
      end
      resources :speakers, only: [:index, :show]
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
