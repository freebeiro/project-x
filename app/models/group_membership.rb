# frozen_string_literal: true

# Represents a membership of a user in a group
class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id }
end
