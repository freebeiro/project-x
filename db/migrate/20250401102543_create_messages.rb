# frozen_string_literal: true

# Migration to create the messages table for group/event chat
class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text :content, null: false # Added null: false constraint
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    # Add index for efficient lookup of messages within a group/event chat
    add_index :messages, %i[group_id event_id created_at]
  end
end
