# frozen_string_literal: true

# Represents a user's profile in the application
class Profile < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :age, numericality: { greater_than_or_equal_to: 18 }
end
