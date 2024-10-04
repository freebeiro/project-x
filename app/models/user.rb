# frozen_string_literal: true

# User model representing authentication
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy

  validates :date_of_birth, presence: true
  validate :minimum_age

  has_many :administered_groups, class_name: 'Group', foreign_key: 'admin_id', dependent: :destroy, inverse_of: :admin

  private

  def minimum_age
    return if date_of_birth.blank?

    return unless date_of_birth > 18.years.ago.to_date

    errors.add(:date_of_birth, 'You should be over 18 years old.')
  end
end
