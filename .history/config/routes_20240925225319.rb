# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             },
             defaults: { format: :json }

  # Add a root route
  root 'application#index'
end
