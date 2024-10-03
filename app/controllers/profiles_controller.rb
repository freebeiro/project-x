# frozen_string_literal: true

# Controller for managing user profiles
class ProfilesController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_profile

  def show
    render json: @profile, status: :ok
  end

  def update
    if @profile.update(profile_params)
      render json: @profile, status: :ok
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile || current_user.create_profile
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :age, :username, :description, :occupation)
  end
end
