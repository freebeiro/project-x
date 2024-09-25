# frozen_string_literal: true

module Users
  # RegistrationsController
  # Handles user registration process
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    def create
      build_resource(sign_up_params)

      if resource.save
        token = JwtService.encode(user_id: resource.id)
        render json: {
          status: { code: 200, message: 'Signed up successfully.' },
          data: {
            id: resource.id,
            email: resource.email,
            created_at: resource.created_at,
            token:
          }
        }, status: :created
      else
        render json: {
          status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
        }, status: :unprocessable_entity
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :date_of_birth)
    end
  end
end
