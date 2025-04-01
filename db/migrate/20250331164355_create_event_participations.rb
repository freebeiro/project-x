# frozen_string_literal: true

# Migration to create the event_participations join table
class CreateEventParticipations < ActiveRecord::Migration[7.1]
  def change
    create_table :event_participations do |t|
      # Foreign keys linking users and events
      t.references :user, null: false, foreign_key: true, index: true
      t.references :event, null: false, foreign_key: true, index: true

      # Status of the participation (e.g., 'attending', 'waitlisted')
      t.string :status, null: false

      t.timestamps # Adds created_at and updated_at columns
    end

    # Add a unique index to ensure a user can only participate in an event once
    add_index :event_participations, %i[user_id event_id], unique: true,
                                                           name: 'index_event_participations_on_user_and_event'
  end
end
