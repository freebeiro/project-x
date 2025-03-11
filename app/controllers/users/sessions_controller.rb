# frozen_string_literal: true

module Users
  # SessionsController
  # Handles user authentication process
  class SessionsController < Devise::SessionsController
    respond_to :json
    skip_before_action :verify_signed_out_user, only: :destroy

    def create
      token = extract_token_from_header
      Rails.logger.debug { "Login attempt - token from header: #{token}" }

      if token && valid_token?(token)
        # User is already logged in with a valid token
        user_id = JwtService.decode(token)['user_id']
        user = User.find_by(id: user_id)

        if user
          Rails.logger.debug { "User already logged in with token: #{user.email}" }
          render json: { error: 'You are already logged in.' }, status: :bad_request
        else
          Rails.logger.debug { "Valid token but user not found for ID: #{user_id}" }
          render json: { error: 'Invalid token provided.' }, status: :unauthorized
        end
      else
        if token && !valid_token?(token)
          Rails.logger.debug { 'Invalid token provided for login' }
          render json: { error: 'Invalid token provided.' }, status: :unauthorized
          return
        end

        # Proceed with normal authentication
        Rails.logger.debug { 'Proceeding with regular authentication' }
        handle_regular_authentication
      end
    end

    def destroy
      token = extract_token_from_header
      Rails.logger.debug { "Logout attempt - token: #{token}" }

      if token.nil?
        Rails.logger.debug { 'No token provided for logout' }
        render json: { status: 401, message: 'No active session' }, status: :unauthorized
        return
      end

      if TokenBlacklistService.blacklisted?(token)
        Rails.logger.debug { 'Token already blacklisted' }
        render json: { status: 401, message: 'No active session' }, status: :unauthorized
        return
      end

      payload = JwtService.decode(token)
      unless payload
        Rails.logger.debug { 'Invalid token for logout' }
        render json: { status: 401, message: 'No active session' }, status: :unauthorized
        return
      end

      user = User.find_by(id: payload['user_id'])
      unless user
        Rails.logger.debug { 'User not found for logout' }
        render json: { status: 401, message: 'No active session' }, status: :unauthorized
        return
      end

      # All checks passed, blacklist the token
      if TokenBlacklistService.blacklist(token)
        Rails.logger.debug { 'Token blacklisted successfully' }
        render json: { status: 200, message: 'Logged out successfully' }, status: :ok
      else
        Rails.logger.debug { 'Failed to blacklist token' }
        render json: { status: 401, message: 'No active session' }, status: :unauthorized
      end
    end

    private

    def handle_regular_authentication
      Rails.logger.debug { "Authenticating user with email: #{params.dig(:user, :email)}" }
      self.resource = warden.authenticate!(auth_options)

      Rails.logger.debug { "User authenticated successfully: #{resource.email}" }
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with_authentication_token(resource)
    end

    def respond_with_authentication_token(resource)
      token = JwtService.encode(user_id: resource.id)
      Rails.logger.debug { "Generated token for user: #{resource.email}" }
      render json: authentication_response(resource, token)
    end

    def authentication_response(resource, token)
      {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          id: resource.id,
          email: resource.email,
          token:
        }
      }
    end

    def extract_token_from_header
      auth_header = request.headers['Authorization']
      return nil unless auth_header

      if auth_header.start_with?('Bearer ')
        auth_header.split('Bearer ').last
      else
        auth_header
      end
    end

    def valid_token?(token)
      return false unless token

      # Check if the token is blacklisted
      return false if TokenBlacklistService.blacklisted?(token)

      # Decode the token and check if the user exists
      decoded_token = JwtService.decode(token)
      return false unless decoded_token && decoded_token['user_id']

      true
    end
  end
end
