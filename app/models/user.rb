# frozen_string_literal: true

# User model representing
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy

  # Validations
  validates :date_of_birth, presence: true
  validate :must_be_16_or_older

  private

  def must_be_16_or_older
    return if date_of_birth.nil?

    return unless date_of_birth > 16.years.ago.to_date

    errors.add(:date_of_birth, 'You must be 16 years or older.')
  end
end
