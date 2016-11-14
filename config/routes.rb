Rails.application.routes.draw do
  resources :groups, { format: 'json', except: %i(destroy) } do
    collection do
      get :search
    end
    member do
      post :join
      post :left
      post :invite
      post :reject
      post :cancel
      put :folder
    end
  end

  namespace :internal, { format: 'json' } do
    resources :groups, only: %i(index show)
  end
end
