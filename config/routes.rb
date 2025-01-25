Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    get "up" => "rails/health#show", as: :rails_health_check
    root to: "home#index"

    constraints(Subdomain) do
      get '/', to: 'users#frontpage', as: 'frontpage'
    end

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
    put '/users/:id', to: 'users#update_user'
    post '/update_activity', to: 'users#update_activity'

    # Friendship
    get '/friends', to: 'friendships#index'
    resources :users do
      resources :friendships, only: [:create, :update, :destroy] do
        member do
          delete :cancel
        end
      end
    end
    get '/requests', to: 'friendships#requests'

    # Sessions
    resources :sessions do
      post 'logout_other_sessions', on: :collection
    end

    # Games
    get '/games/new', to: 'games#new'
    post '/games', to: 'games#create'
    get '/games/:id/edit', to: 'games#edit', as: 'game_edit'
    patch '/games/:id', to: 'games#update', as: 'game_update'
    delete '/games/:id', to: 'games#destroy', as: 'game_destroy'
    get '/games/:id', to: "games#show", as: 'game_profile'
    get '/games_showcase', to: 'games#showcase'
    post '/games/:id/submit', to: 'games#submit', as: 'submit'

    # Jams
    get '/jams/new', to: 'jams#new'
    post '/jams', to: 'jams#create'
    get '/jams/:id/edit', to: 'jams#edit', as: 'jam_edit'
    get '/jams/:id/setting_judges', to: 'jams#setting_judges', as: 'jam_setting_judges'
    patch '/jams/:id', to: 'jams#update', as: 'jam_update'
    delete '/jams/:id', to: 'jams#destroy', as: 'jam_destroy'
    get '/jams/:id', to: "jams#show", as: 'jam_profile'
    get '/jams_showcase', to: 'jams#showcase'
    get '/jams/:id/submit_game', to: 'jams#submit_game', as: 'game_submission'
    post '/jams/:id/submit_game', to: 'jams#create_submission'
    get '/jams/:id/show_projects', to: 'jams#show_projects', as: 'jam_show_projects'
    get '/jams/:id/show_participants', to: 'jams#show_participants', as: 'jam_show_participants'

    resources :jams do
      member do
        post 'participate'
        patch 'delete_project'
        post 'add_contributor'
        patch 'update_contributor', to: 'jams#update_contributor', as: 'update_contributor'
        delete 'delete_contributor/:user_id', to: 'jams#delete_contributor', as: 'delete_contributor'
      end
    end
    resources :games do
      resources :reviews, only: [:destroy]
      resources :ratings, only: [:create]
    end

    resources :notifications, only: [:index, :show] do
      delete 'destroy_all_notifications', on: :collection
    end
    patch '/notifications/mark_as_read', to: 'notifications#mark_as_read'

    get '/notifications', to: 'notifications#index'

    get '/settings', to: 'settings#index'


  resource :password_reset, only: [:new, :create, :edit, :update]
  resource :email_confirm, only: [:new, :create, :edit, :update]
  end
end