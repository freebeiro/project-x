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

  accepts_nested_attributes_for :profile

  has_many :friendships
  has_many :friends, through: :friendships

  def friends_with?(other_user)
    Friendship.where(user: self, friend: other_user, status: 'accepted')
              .or(Friendship.where(user: other_user, friend: self, status: 'accepted'))
              .exists?
  end

  private

  def minimum_age
    return if date_of_birth.blank?

    return unless date_of_birth > 18.years.ago.to_date

    errors.add(:date_of_birth, 'You should be over 18 years old.')
  end
end
