# frozen_string_literal: true

# TokenBlacklistService
# Handles blacklisting of JWT tokens
class TokenBlacklistService
  def self.blacklist(token)
    BlacklistedToken.create(token:, expires_at: 24.hours.from_now)
  end

  def self.blacklisted?(token)
    BlacklistedToken.exists?(token:)
  end
end
