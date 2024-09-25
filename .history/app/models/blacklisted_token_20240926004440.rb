# Represents a blacklisted token in the system
class BlacklistedToken < ApplicationRecord
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }
end
