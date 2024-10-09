# frozen_string_literal: true

# This migration creates the friendships table to manage user relationships.
class CreateFriendships < ActiveRecord::Migration[7.1]
  def change
    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :friendships, %i[user_id friend_id], unique: true
  end
end
