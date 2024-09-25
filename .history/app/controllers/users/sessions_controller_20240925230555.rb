# frozen_string_literal: true

module Users
  # SessionsController
  # Handles user authentication process
  class SessionsController < Devise::SessionsController
    respond_to :json

    def create
      super { @token = current_token }
    end

    private

    def current_token
      JwtService.encode(user_id: current_user.id) if current_user
    end

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render_success_response(resource)
      else
        render_error_response
      end
    end

    def respond_to_on_destroy
      if current_user
        render json: {
          status: 200,
          message: 'Logged out successfully'
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    end

    def render_success_response(resource)
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: user_data(resource)
      }, status: :ok
    end

    def render_error_response
      render json: {
        status: 401,
        message: 'Invalid email or password.'
      }, status: :unauthorized
    end

    def user_data(user)
      {
        id: user.id,
        email: user.email,
        token: @token
      }
    end
  end
end
