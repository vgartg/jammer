Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # Registration and Auth
  get "/register", to: "users#new"
  post "/register", to: "users#create"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  delete '/destroy', to: "users#destroy", as: 'user_destroy'

  # Auth Zone
  get '/dashboard', to: "dashboard#index"
  get '/users/:id', to: "users#show", as: 'user_profile'
  get '/users', to: "users#index"

  # Edit/Update user
  get '/edit_user', to: "users#edit_user"
  put '/users/:id', to: 'users#update_user'
  post 'update_activity', to: 'users#update_activity'

  # Friendship
  get '/friends', to: 'friendships#index'
  resources :users do
    resources :friendships, only: [:create, :update, :destroy] do
      member do
        delete :cancel
      end
    end
  end

  # Games
  get '/games/new', to: 'games#new'
  post '/games', to: 'games#create'
  get '/games/:id/edit', to: 'games#edit', as: 'game_edit'
  patch '/games/:id', to: 'games#update', as: 'game_update'
  delete '/games/:id', to: 'games#destroy', as: 'game_destroy'
  get '/games/:id', to: "games#show", as: 'game_profile'
  get '/games_showcase', to: 'games#showcase'


  # Debug
  if Rails.env.development?
    redirector = ->(params, _) { ApplicationController.helpers.asset_path("#{params[:name].split('-').first}.map") }
    constraint = ->(request) { request.path.ends_with?(".map") }
    get "assets/*name", to: redirect(redirector), constraints: constraint
  end

end
