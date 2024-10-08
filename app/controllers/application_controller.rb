# frozen_string_literal: true

# Base controller for the application
class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  attr_reader :current_user

  private

  def authenticate_user_from_token!
    token = extract_token_from_header
    Rails.logger.debug { "Token received: #{token}" }
    return render_unauthorized if invalid_token?(token)

    payload = decode_token(token)
    Rails.logger.debug { "Decoded payload: #{payload}" }
    return render_unauthorized unless payload

    @current_user = find_user(payload)
    Rails.logger.debug { "Current user: #{@current_user&.id}" }
    render_unauthorized unless @current_user

    @current_user
  end

  def invalid_token?(token)
    token.nil? || TokenBlacklistService.blacklisted?(token)
  end

  def decode_token(token)
    payload = JwtService.decode(token)
    payload if payload&.dig('user_id')
  end

  def find_user(payload)
    User.find_by(id: payload['user_id'])
  end

  def render_unauthorized
    render json: { status: 401, message: 'Unauthorized' }, status: :unauthorized
  end

  def extract_token_from_header
    request.headers['Authorization']&.split('Bearer ')&.last
  end
end
