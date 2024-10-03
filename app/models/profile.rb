# frozen_string_literal: true

# Represents a user's profile in the application
class Profile < ApplicationRecord
  belongs_to :user

  validates :first_name, :last_name, :age, :username, :occupation, presence: true
  validates :age, numericality: { greater_than_or_equal_to: 18 }
  validates :username, uniqueness: true
  validates :description, length: { maximum: 1000 }

  def name
    "#{first_name} #{last_name}"
  end
end
