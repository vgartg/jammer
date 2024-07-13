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

  # Auth Zone

  get '/dashboard', to: "dashboard#index"
  get '/users/:id', to: "users#show", as: 'user_profile'

  # Games

  get '/game_create', to: 'games#new'
  post '/game_create', to: 'games#create'

  get '/games_showcase', to: 'games#showcase'

end
