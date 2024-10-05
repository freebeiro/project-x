# frozen_string_literal: true

# User model representing authentication
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy

  validates :date_of_birth, presence: true
  validate :minimum_age

  has_many :administered_groups, class_name: 'Group', foreign_key: 'admin_id', dependent: :destroy, inverse_of: :admin

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :received_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy,
                                  inverse_of: :friend
  has_many :received_friends, through: :received_friendships, source: :user

  private

  def minimum_age
    return if date_of_birth.blank?

    return unless date_of_birth > 18.years.ago.to_date

    errors.add(:date_of_birth, 'You should be over 18 years old.')
  end
end
