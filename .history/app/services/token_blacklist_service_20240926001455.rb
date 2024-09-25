# frozen_string_literal: true

# TokenBlacklistService
# Handles blacklisting of JWT tokens
class TokenBlacklistService
  @blacklist = []

  class << self
    def blacklist(token)
      @blacklist << token
    end

    def blacklisted?(token)
      @blacklist.include?(token)
    end
  end
end
