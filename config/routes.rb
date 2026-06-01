require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    match '/404', to: 'errors#not_found', via: :all, as: :not_found_error
    match '/500', to: 'errors#internal_server_error', via: :all, as: :internal_server_error
    get 'up' => 'rails/health#show', as: :rails_health_check
    root to: 'home#index'

    get '/u/:username', to: 'users#frontpage', as: 'frontpage'

    # Registration and Auth
    get '/register', to: 'users#new'
    post '/register', to: 'users#create'
    get '/login', to: 'sessions#new'
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy'
    delete '/destroy', to: 'users#destroy', as: 'user_destroy'

    # OAuth
    get '/auth/:provider/callback', to: 'oauth#callback', as: 'oauth_callback'
    get '/auth/failure', to: 'oauth#failure', as: 'oauth_failure'

    # Auth Zone
    get '/news', to: 'dashboard#index', as: 'news'
    get '/dashboard', to: redirect { |params, _req| params[:locale].present? ? "/#{params[:locale]}/news" : '/news' }

    get '/users/:id', to: 'users#show', as: 'user_profile'
    get '/users', to: 'users#index'

    # Edit/Update user
    put '/users/:id', to: 'users#update_user'
    post '/update_activity', to: 'users#update_activity'

    # Friendship
    get '/friends', to: 'friendships#index'
    resources :users do
      resources :friendships, only: %i[create update destroy] do
        member do
          delete :cancel
        end
      end
    end
    get '/requests', to: 'friendships#requests'

  # Sessions
    resources :sessions do
      post 'logout_other_sessions', on: :collection
      post 'logout_all_sessions', on: :collection
      post 'logout_one_session', on: :collection
    end

    # Assets
    get '/assets', to: 'assets#index', as: 'assets'
    get '/assets/new', to: 'assets#new', as: 'new_asset'
    post '/assets', to: 'assets#create'
    get '/assets/:id', to: 'assets#show', as: 'asset_profile'
    get '/assets/:id/edit', to: 'assets#edit', as: 'asset_edit'
    patch '/assets/:id', to: 'assets#update', as: 'asset_update'
    delete '/assets/:id', to: 'assets#destroy', as: 'asset_destroy'
    get '/assets/:id/download', to: 'assets#download', as: 'asset_download'

    # Teams
    get '/teams', to: 'teams#index', as: 'teams'
    get '/teams/new', to: 'teams#new', as: 'new_team'
    post '/teams', to: 'teams#create'
    get '/teams/:id', to: 'teams#show', as: 'team_profile'
    get '/teams/:id/edit', to: 'teams#edit', as: 'team_edit'
    patch '/teams/:id', to: 'teams#update', as: 'team_update'
    delete '/teams/:id', to: 'teams#destroy', as: 'team_destroy'
    get '/teams/:id/invite_search', to: 'teams#invite_search', as: 'team_invite_search'
    post '/teams/:id/invite', to: 'team_memberships#invite', as: 'team_invite'
    resources :teams, only: [] do
      resources :team_memberships, only: %i[create update destroy]
    end

    # Games
    get '/games/new', to: 'games#new'
    post '/games', to: 'games#create'
    get '/games/:id/edit', to: 'games#edit', as: 'game_edit'
    patch '/games/:id', to: 'games#update', as: 'game_update'
    delete '/games/:id', to: 'games#destroy', as: 'game_destroy'
    get '/games/:id', to: 'games#show', as: 'game_profile'
    get '/games_showcase', to: 'games#showcase'
    post '/games/:id/submit', to: 'games#submit', as: 'submit'

    # Jams
    get '/jams/new', to: 'jams#new'
    post '/jams', to: 'jams#create'
    get '/jams/:id/edit', to: 'jams#edit', as: 'jam_edit'
    patch '/jams/:id', to: 'jams#update', as: 'jam_update'
    delete '/jams/:id', to: 'jams#destroy', as: 'jam_destroy'
    get '/jams/:id', to: 'jams#show', as: 'jam_profile'
    get '/jams_showcase', to: 'jams#showcase'
    get '/jams/:id/submit_game', to: 'jams#submit_game', as: 'game_submission'
    post '/jams/:id/submit_game', to: 'jams#create_submission'
    get '/jams/:id/show_projects', to: 'jams#show_projects', as: 'jam_show_projects'
    get '/jams/:id/show_participants', to: 'jams#show_participants', as: 'jam_show_participants'

    get  "/jams/:jam_id/games/:game_id/vote", to: "jam_votes#new", as: :new_jam_game_vote
    post "/jams/:jam_id/games/:game_id/vote", to: "jam_votes#create", as: :jam_game_vote

    patch "jams/:id/nominations/:nomination_id/winner", to: "jams#update_nomination_winner", as: :update_nomination_winner_jam

    resources :jams do
      resources :games do
        resource :vote, only: %i[new create], controller: "jam_votes"
      end

      resources :jam_criterion_picks, only: %i[create destroy]
    end

    resources :jams do
      member do
        post 'participate'
        patch 'delete_project'
        delete 'remove_participant', to: 'jams#remove_participant'
        delete 'remove_project', to: 'jams#remove_project'

        get  :rating_settings
        patch :rating_settings, action: :update_rating_settings

        get  :jury_settings
        get :jury_search
        post :jury_invite
        patch :bulk_update_contributors
        patch "jury_settings/:contributor_id", to: "jams#update_contributor", as: :update_contributor
        delete "jury_settings/:contributor_id", to: "jams#remove_contributor", as: :remove_contributor

        patch "jury_settings/:contributor_id/accept", to: "jams#accept_contributor_invite", as: :accept_contributor_invite
      end
    end
    resources :games do
      resources :reviews, only: [:destroy]
      resources :ratings, only: [:create]
    end

    resources :notifications, only: %i[index show destroy] do
      collection do
        delete 'destroy_all', to: 'notifications#destroy_all'
      end
    end
    patch '/notifications/mark_as_read', to: 'notifications#mark_as_read'

    get '/notifications', to: 'notifications#index'

    get '/settings', to: 'settings#index'
    get '/frozen', to: 'frozen#show', as: 'frozen'
    get '/contacts', to: 'contacts#index', as: 'contacts'
    get '/achievements', to: 'achievements#index', as: 'achievements'
    get '/achievements/panel', to: 'achievements#panel', as: 'achievements_panel'

  # Admin
  get '/admin', to: 'admins#index'
  namespace :admin do
    %i[actions visits].each do |resource|
      resources resource, only: %i[index]
    end
    %i[users games jams].each do |resource|
      resources resource, only: %i[index new create edit update destroy]
    end
    resources :users do
      collection { get :search }
      member do
        post :freeze
        post :unfreeze
        delete :destroy_notification
      end
    end
    get '/visits_data', to: 'visits#visits_data'
    get '/registrations_data', to: 'visits#registrations_data'
    resources :announcements, only: %i[index new create edit update destroy]
    resources :teams, only: %i[index destroy]
    resources :assets, only: %i[index destroy]
    resources :achievements, only: %i[index create destroy]
    resources :messages, only: %i[new create]
  end

  # Moderator
  get '/moderator', to: 'moderators#index'
  namespace :moderator do
    %i[games jams].each do |resource|
      resources resource, only: %i[index edit update destroy]
    end
    resources :audit, only: :index
  end

  resources :reports, only: [:create]

  # Email (mailer)
  resource :password_reset, only: %i[new create edit update]
  resource :email_confirm, only: %i[new create edit update]
  end
end
