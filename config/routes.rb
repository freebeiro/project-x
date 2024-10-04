# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }, defaults: { format: :json }

  # Add a root route
  root 'application#index'

  resource :profile, only: %i[show update]

  resources :groups, only: [:create]
end
