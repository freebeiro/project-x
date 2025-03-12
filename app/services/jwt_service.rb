# frozen_string_literal: true

# Service for handling JWT tokens
class JwtService
  # Use a hardcoded secret key for development
  SECRET_KEY = '0bc347d905b7d9e4afd9395b8e9b3dc56646d6fc6205413d3f537dada4c978152d4f53eb08138cafeaafc577df724ad8e43114a12130463a93874180a84a6c4e'

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    ::JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    # Return nil for nil tokens
    return nil if token.nil?

    begin
      # Decode the token
      body = ::JWT.decode(token, SECRET_KEY)[0]
      ActiveSupport::HashWithIndifferentAccess.new body
    rescue ::JWT::DecodeError => e
      Rails.logger.debug "Failed to decode JWT token: #{e.message}"
      nil
    end
  end
end
