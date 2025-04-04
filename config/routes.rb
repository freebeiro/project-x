# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Mount Action Cable server
  mount ActionCable.server => '/cable'

  # Existing routes
  resources :groups do
    post 'group_membership', to: 'group_memberships#create'
    delete 'group_membership', to: 'group_memberships#destroy'

    # Nested events within groups
    resources :events do
      # Nested messages within events (which are within groups)
      namespace :api do
        namespace :v1 do
          resources :messages, only: %i[index create]
          resources :posts, only: %i[index create] # Added posts route
        end
      end
      # Nested participations within events
      resources :participations, only: %i[create index destroy], controller: 'event_participations'
    end
  end

  # Add these new routes (Friendships, Profiles)
  resources :friendships, only: %i[create destroy] do
    collection do
      put :accept
      put :decline
    end
  end

  resources :profiles, only: [:show] # Keep top-level route for viewing any profile by user_id
  resource :profile, only: %i[show update] # Keep singular route for current_user's profile

  get 'users/search', to: 'users#search'
end

# rubocop:enable Metrics/BlockLength
