Rails.application.routes.draw do

	root 'sessions#new'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
	
  get '/signup', to: 'users#new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :users do
  	member do
      get :following, :followers
      get :past_following, :past_followers
    end
  	collection do
      get :friend
      get :search
    end
  end

  resources :account_activations, only: [:edit]
  resources :albums do
  	collection do
      get :change_past_now
    end
  end
  resources :photos

  resources :relationships
end
