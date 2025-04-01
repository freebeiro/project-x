# frozen_string_literal: true

# Represents an event organized by a user.
# Events have details like name, description, time, location, and capacity.
# Users can participate in events.
class Event < ApplicationRecord
  # Associations
  # The user who created the event.
  belongs_to :organizer, class_name: 'User'
  # The group this event belongs to.
  belongs_to :group
  # Join records linking this event to participating users.
  has_many :event_participations, dependent: :destroy
  # Users participating in this event through the join table.
  has_many :participants, through: :event_participations, source: :user
  # Messages associated with this event's chat
  has_many :messages, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 3 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :end_time_after_start_time

  # Returns true if the event has reached its participant capacity
  def at_capacity?
    participants.count >= capacity
  end

  private

  # Custom validation to ensure the event's end time is after its start time.
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    return unless end_time <= start_time

    errors.add(:end_time, 'must be after the start time')
  end
end
