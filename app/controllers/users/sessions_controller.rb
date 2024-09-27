# frozen_string_literal: true

module Users
  # SessionsController
  # Handles user authentication process
  class SessionsController < Devise::SessionsController
    respond_to :json
    skip_before_action :verify_signed_out_user, only: :destroy

    def create
      token = extract_token_from_header

      if token && valid_token?(token)
        # If a valid token is present, the user is already logged in
        render json: { error: 'You are already logged in.' }, status: :bad_request
      else
        # If no valid token, proceed with login
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)
        yield resource if block_given?
        respond_with_authentication_token(resource)
      end
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
          user: {
            id: resource.id,
            email: resource.email
          },
          token:
        }
      }
    end

    def extract_token_from_header
      request.headers['Authorization']&.split('Bearer ')&.last
    end

    def valid_token?(token)
      return false unless token

      # Check if the token is blacklisted
      return false if TokenBlacklistService.blacklisted?(token)

      # Decode the token and check if the user exists
      decoded_token = JwtService.decode(token)
      return false unless decoded_token

      user = User.find_by(id: decoded_token['user_id'])
      user.present?
    end
  end
end
