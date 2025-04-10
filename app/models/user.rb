# frozen_string_literal: true

# User model representing authentication
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy # Removed autosave: true

  validates :date_of_birth, presence: true
  validate :minimum_age

  has_many :administered_groups, class_name: 'Group', foreign_key: 'admin_id', dependent: :destroy, inverse_of: :admin

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  # Event related associations
  # Events organized by this user.
  has_many :organized_events, class_name: 'Event', foreign_key: 'organizer_id', dependent: :destroy,
                              inverse_of: :organizer
  # Join records linking this user to events they are participating in.
  has_many :event_participations, dependent: :destroy
  # Events this user is participating in.
  has_many :participating_events, through: :event_participations, source: :event
  # Messages sent by this user.
  has_many :messages, dependent: :destroy
  # Posts created by this user.
  has_many :posts, dependent: :destroy

  accepts_nested_attributes_for :profile

  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { status: 'accepted' }) },
           through: :friendships,
           source: :friend

  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy,
                                 inverse_of: :friend
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  def friends_with?(other_user)
    Friendship.where(user: self, friend: other_user, status: 'accepted')
              .or(Friendship.where(user: other_user, friend: self, status: 'accepted'))
              .exists?
  end

  private

  def minimum_age
    # Ensure date_of_birth is present before calculating age
    return if date_of_birth.blank?

    # Check if the date of birth is less than 16 years ago
    # Note: Using '<=' ensures that someone whose 16th birthday is today is allowed
    return unless date_of_birth > 16.years.ago.to_date

    # Add an error if the user is younger than 16
    errors.add(:date_of_birth, 'You must be at least 16 years old.')
  end
end
