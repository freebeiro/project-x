# frozen_string_literal: true

# Migration to add the mandatory group reference to the events table
class AddGroupRefToEvents < ActiveRecord::Migration[7.1]
  def change
    # rubocop:disable Rails/NotNullColumn
    add_reference :events, :group, null: false, foreign_key: true
    # rubocop:enable Rails/NotNullColumn
  end
end
