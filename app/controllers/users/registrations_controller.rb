# frozen_string_literal: true

module Users
  # RegistrationsController
  # Handles user registration process
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    def create
      build_resource(sign_up_params)
      resource.save
      render_response(resource)
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :date_of_birth,
                                   profile_attributes: %i[first_name last_name age username occupation description])
    end

    def render_response(resource)
      if resource.persisted?
        render_success_response(resource)
      else
        render_error_response(resource)
      end
    end

    def render_success_response(resource)
      token = JwtService.encode(user_id: resource.id)
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: user_data(resource, token)
      }, status: :created
    end

    def render_error_response(resource)
      render json: {
        status: { message: error_message(resource) }
      }, status: :unprocessable_entity
    end

    def user_data(user, token)
      {
        id: user.id,
        email: user.email,
        created_at: user.created_at,
        token:,
        profile: user.profile
      }
    end

    def error_message(resource)
      "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"
    end
  end
end
