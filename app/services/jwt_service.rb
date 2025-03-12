# frozen_string_literal: true

# Service for handling JWT tokens
class JwtService
  # Use environment variable for secret key
  SECRET_KEY = ENV.fetch('JWT_SECRET_KEY') do
    raise 'JWT_SECRET_KEY environment variable is not set! Please configure it in your .env file.'
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    # Return nil for nil tokens
    return nil if token.nil?

    begin
      # Decode the token
      decoded = JWT.decode(token, SECRET_KEY)[0]
      ActiveSupport::HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.debug { "JWT decoding error: #{e.message}" }
      nil
    end
  end
end
