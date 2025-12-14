# Staff website management routes (beta feature)
# These routes are kept separate as the website feature is incomplete

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
