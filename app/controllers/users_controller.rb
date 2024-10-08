# frozen_string_literal: true

# Controller for user-related actions
class UsersController < ApplicationController
  before_action :authenticate_user_from_token!

  def search
    user = User.joins(:profile).find_by('LOWER(profiles.username) = ?', params[:username].downcase)
    if user
      render json: {
        id: user.id,
        email: user.email,
        username: user.profile.username
      }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end
end
