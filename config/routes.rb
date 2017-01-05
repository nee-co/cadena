Rails.application.routes.draw do
  resources :groups, { format: 'json', only: %i(show create update) } do
    collection do
      get :index, controller: :tray
      get :invitations, controller: :tray
      get :search
    end
    member do
      get :members
      get :invitees
      post :join
      post :left
      post :invite
      post :reject
      post :cancel
    end
  end

  namespace :internal, { format: 'json' } do
    resources :groups, only: %i(index)
  end
end
