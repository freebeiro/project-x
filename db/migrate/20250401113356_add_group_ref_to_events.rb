# frozen_string_literal: true

# Migration to add the mandatory group reference to the events table
class AddGroupRefToEvents < ActiveRecord::Migration[7.1]
  def change
    add_reference :events, :group, null: false, foreign_key: true
  end
end
