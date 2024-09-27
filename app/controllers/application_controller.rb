# frozen_string_literal: true

# Base controller for the application
class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  private

  def authenticate_user_from_token!
    token = extract_token_from_header
    return render_unauthorized if token.nil? || TokenBlacklistService.blacklisted?(token)
  
    payload = JwtService.decode(token)
    return render_unauthorized unless payload&.dig('user_id')
  
    @current_user = User.find_by(id: payload['user_id'])
    render_unauthorized unless @current_user
  end
  

  def render_unauthorized
    render json: { status: 401, message: 'Unauthorized' }, status: :unauthorized
  end

  def extract_token_from_header
    request.headers['Authorization']&.split('Bearer ')&.last
  end
end
