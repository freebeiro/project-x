# frozen_string_literal: true

# TokenBlacklistService
# Handles blacklisting of JWT tokens
class TokenBlacklistService
  @blacklist = []

  class << self
    def blacklist(token)
      # In a real application, you'd store this in Redis or a database
      # For now, we'll use a class variable (not suitable for production)
      @blacklist << token
    end

    def blacklisted?(token)
      @blacklist.include?(token)
    end
  end
end
