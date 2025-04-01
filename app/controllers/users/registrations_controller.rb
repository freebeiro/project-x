# frozen_string_literal: true

module Users
  # RegistrationsController
  # Handles user registration process
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    def create
      # Standard implementation using nested attributes permitted via sign_up_params
      build_resource(sign_up_params)
      resource.save
      render_response(resource)
    end

    private

    def sign_up_params
      params.require(:user).permit(
        :email, :password, :password_confirmation, :date_of_birth,
        profile_attributes: %i[first_name last_name age username description occupation]
      )
    end

    # profile_params method is no longer needed as attributes are handled via nesting
    # def profile_params
    #   params.fetch(:profile, {}).permit(:first_name, :last_name, :age, :username, :description, :occupation)
    # end

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

    # Reverted argument name
    def render_error_response(resource)
      render json: {
        status: { message: error_message(resource) }
      }, status: :unprocessable_entity
    end

    # Reverted argument name
    def user_data(user, token)
      {
        id: user.id,
        email: user.email,
        created_at: user.created_at,
        token:,
        profile: user.profile
      }
    end

    # Reverted argument name
    def error_message(resource)
      # Combine errors from user and profile (if profile exists and has errors)
      user_errors = resource.errors.full_messages
      profile_errors = resource.profile&.errors&.full_messages || []
      combined_errors = (user_errors + profile_errors).uniq
      "User couldn't be created successfully. #{combined_errors.to_sentence}"
    end
  end
end
