# frozen_string_literal: true

# TokenBlacklistService
# Handles blacklisting of JWT tokens
class TokenBlacklistService
  @blacklist = []

  class << self
    def blacklist(token)
      return false if token.nil? || @blacklist.include?(token)

      @blacklist << token
      true
    end

    def blacklisted?(token)
      @blacklist.include?(token)
    end
  end
end
