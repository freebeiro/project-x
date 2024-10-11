# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Existing routes
  resources :groups do
    post 'group_membership', to: 'group_memberships#create'
    delete 'group_membership', to: 'group_memberships#destroy'
  end

  # Add these new routes
  resources :friendships, only: %i[create destroy] do
    collection do
      put :accept
      put :decline
    end
  end

  resources :profiles, only: [:show]
  resource :profile, only: %i[show update]

  # Keep any other existing routes

  get 'users/search', to: 'users#search'
end
