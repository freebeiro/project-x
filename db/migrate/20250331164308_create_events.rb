# frozen_string_literal: true

# Migration to create the events table
class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      # Event details
      t.string :name, null: false, index: true # Name of the event, required and indexed
      t.text :description # Optional description of the event
      t.datetime :start_time, null: false # Start date and time, required
      t.datetime :end_time, null: false # End date and time, required
      t.string :location # Location of the event
      t.integer :capacity, null: false, default: 10 # Maximum number of participants, required with default

      # Foreign key for the user who organized the event
      t.references :organizer, null: false, foreign_key: { to_table: :users }, index: true

      t.timestamps # Adds created_at and updated_at columns
    end
  end
end
