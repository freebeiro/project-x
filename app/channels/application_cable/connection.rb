# frozen_string_literal: true

module ApplicationCable
  # Handles WebSocket connection authentication and identification.
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', "User #{current_user.id}" if current_user
    end

    private

    def find_verified_user
      # Expect token to be passed as a query parameter, e.g., ws://localhost:3005/cable?token=JWT_TOKEN
      token = request.params[:token]
      verified_user = if token.present?
                        begin
                          decoded_token = JwtService.decode(token)
                          User.find(decoded_token[:user_id])
                        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
                          nil # Return nil if token invalid or user not found
                        end
                      end

      verified_user || reject_unauthorized_connection
    end
  end
end
