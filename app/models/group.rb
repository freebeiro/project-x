# frozen_string_literal: true

# Group represents a group in the application
class Group < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :users, through: :group_memberships

  validates :name, presence: true
  validates :privacy, inclusion: { in: %w[public private] }
  validates :member_limit, numericality: { greater_than: 0 }
end
