# frozen_string_literal: true

# Represents a friendship between users.
class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  enum :status, { pending: 'pending', accepted: 'accepted', declined: 'declined' }

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self_friendship

  private

  def not_self_friendship
    errors.add(:friend, "can't be the same as the user") if user_id == friend_id
  end
end
