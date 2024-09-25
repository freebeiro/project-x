# frozen_string_literal: true

module Users
  # SessionsController
  # Handles user authentication process
  class SessionsController < Devise::SessionsController
    respond_to :json
    skip_before_action :verify_signed_out_user, only: :destroy

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with_authentication_token(resource)
    end

    def destroy
      token = extract_token_from_header
      if token && TokenBlacklistService.blacklist(token)
        render json: { status: 200, message: 'Logged out successfully' }, status: :ok
      else
        render json: { status: 401, message: 'Invalid or missing token' }, status: :unauthorized
      end
    end

    private

    def respond_with_authentication_token(resource)
      token = JwtService.encode(user_id: resource.id)
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          id: resource.id,
          email: resource.email,
          token:
        }
      }
    end

    def extract_token_from_header
      request.headers['Authorization']&.split('Bearer ')&.last
    end
  end
end
