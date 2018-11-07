Rails.application.routes.draw do
  resources :users, only: [:show, :create, :update] do
    collection do
      post :verify_code
    end
  end

  resources :authenticate, path: :auth, only: [] do
    collection do
      post :login
      post :logout
    end
  end

  resources :images, only: [:show, :create, :destroy] do
    member do
      get :get_with_size
    end
  end

  resources :companies, only: [:show, :create, :update]
  resources :employees, only: [:show, :create, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
