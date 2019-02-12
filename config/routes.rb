Rails.application.routes.draw do
  resources :news
  resources :ban_lists, path: 'black_list', only: [:index, :show, :create]
  get 'black_list/:black_list_id/black_list_comments', to: 'ban_list_comments#index'
  post 'black_list/:black_list_id/black_list_comments', to: 'ban_list_comments#create'

  resources :users, only: [:show, :create, :update] do
    collection do
      post :verify_code
      post :invite
      get :my
      # TODO: remove
      post :pay
      post :make_admin
    end
  end

  resources :authenticate, path: :auth, only: [] do
    collection do
      post :login
      post :logout
      post :forgot_password
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
    resources :employee_offers, only: [:index, :show, :create]
    resources :employee_comments, only: [:index, :create]
    collection do
      get :dashboard
    end
  end

  resources :vacancies, only: [:index, :show] do
    resources :vacancy_responses, only: [:index, :create]
    collection do
      get :dashboard
    end
  end

  resources :payments, only: [:create] do
    collection do
      post :result
    end
  end

  resources :admin_ban_lists, path: 'admin_black_list', only: [:index] do
    member do
      post :approve
      post :deny
    end
  end

  resources :admin_employees, only: [:index, :show] do
    member do
      post :approve
      post :deny
    end
  end

  resources :admin_vacancies, only: [:index, :show] do
    member do
      post :approve
      post :deny
    end
  end

  resources :admin_users, only: [:index] do
    member do
      post :block
    end
  end

  resources :admin_ban_list_comments, path: 'admin_black_list_comments', only: [:destroy]
  resources :admin_employee_comments, only: [:destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
