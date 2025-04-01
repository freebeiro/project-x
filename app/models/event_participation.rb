# frozen_string_literal: true

# Represents the participation of a User in an Event.
# This join model tracks the status of a user's involvement (e.g., attending, waitlisted).
class EventParticipation < ApplicationRecord
  # Constants for participation statuses
  STATUS_ATTENDING = 'attending'
  STATUS_WAITLISTED = 'waitlisted'
  VALID_STATUSES = [STATUS_ATTENDING, STATUS_WAITLISTED].freeze

  # Associations
  belongs_to :user
  belongs_to :event

  # Validations
  # Ensure uniqueness of user per event (handled by database index, but good practice here too)
  validates :user_id, uniqueness: { scope: :event_id }
  # Validate the status is one of the allowed values
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  # Add scope for easy querying? e.g., EventParticipation.attending, EventParticipation.waitlisted
  scope :attending, -> { where(status: STATUS_ATTENDING) }
  scope :waitlisted, -> { where(status: STATUS_WAITLISTED) }
end
