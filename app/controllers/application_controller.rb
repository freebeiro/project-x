# frozen_string_literal: true

# Base controller for the application
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  before_action :configure_permitted_parameters, if: :devise_controller?

  attr_reader :current_user

  private

  def authenticate_user_from_token!
    token = extract_token_from_header
    Rails.logger.debug { "Authenticating with token: #{token}" }

    if token.nil?
      Rails.logger.debug { 'No token provided' }
      return render_unauthorized('Unauthorized')
    end

    if TokenBlacklistService.blacklisted?(token)
      Rails.logger.debug { 'Token is blacklisted' }
      return render_unauthorized('Unauthorized')
    end

    payload = JwtService.decode(token)
    Rails.logger.debug { "Decoded payload: #{payload}" }

    unless payload
      Rails.logger.debug { 'Invalid token' }
      return render_unauthorized('Unauthorized')
    end

    @current_user = find_user(payload['user_id'])
    Rails.logger.debug { "Current user: #{@current_user&.id}" }

    render_unauthorized('Unauthorized') unless @current_user
  end

  def invalid_token?(token)
    token.nil? || TokenBlacklistService.blacklisted?(token)
  end

  def decode_token(token)
    JwtService.decode(token)
  end

  def find_user(user_id)
    Rails.logger.debug { "Finding user with ID: #{user_id}" }
    User.find_by(id: user_id)
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: { status: 401, message: }, status: :unauthorized
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    Rails.logger.debug { "Authorization header: #{auth_header}" }
    return nil unless auth_header

    auth_header.start_with?('Bearer ') ? auth_header.split('Bearer ').last : auth_header
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:date_of_birth])
  end
end
