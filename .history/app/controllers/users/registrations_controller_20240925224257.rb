# frozen_string_literal: true

module Users
  # RegistrationsController
  # Handles user registration process
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :date_of_birth)
    end

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: {
          user: resource,
          token: JwtService.encode({ user_id: resource.id })
        }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
