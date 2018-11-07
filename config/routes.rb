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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
