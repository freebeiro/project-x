# frozen_string_literal: true

# Represents a chat message sent within a group during an event.
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :event

  # Content cannot be empty
  validates :content, presence: true, length: { minimum: 1 } # Ensure non-empty content
end
