Rails.application.routes.draw do
  resources :ban_lists, path: 'black_list', only: [:index, :create]

  resources :users, only: [:show, :create, :update] do
    collection do
      post :verify_code
      post :invite
      get :my
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

  resources :companies, only: [:show, :create, :update] do
    resources :vacancies, only: [:create, :update]
  end
  resources :employees, only: [:index, :show, :create, :update] do
    resources :jobs, only: [:create, :update]
  end

  resources :vacancies, only: [:index, :show] do
    resources :vacancy_responses, only: [:index, :create]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
