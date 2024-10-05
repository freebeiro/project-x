# frozen_string_literal: true

# Represents a friendship between two users
class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, uniqueness: { scope: :friend_id }
  validates :status, inclusion: { in: %w[pending accepted declined] }
end
