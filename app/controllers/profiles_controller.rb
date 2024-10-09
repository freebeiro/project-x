# frozen_string_literal: true

# Controller for managing user profiles
class ProfilesController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_profile, only: %i[show update]

  def show
    if @profile.nil?
      render json: { error: 'Profile not found' }, status: :not_found
    elsif current_user.id == @profile.user_id || current_user.friends_with?(@profile.user)
      render json: { data: @profile.as_json(include: :user, methods: :name) }, status: :ok
    else
      render json: { data: { username: @profile.username } }, status: :ok
    end
  end

  def update
    if @profile.update(profile_params)
      render json: { data: @profile }, status: :ok
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = if params[:id]
                 Profile.find_by(id: params[:id])
               else
                 current_user.profile
               end
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :age, :username, :description, :occupation)
  end
end
