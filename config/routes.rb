Rails.application.routes.draw do
  resources :groups, { format: 'json', except: %i(destroy) } do
    collection do
      get :search
    end
    member do
      get :members
      get :invitations
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
