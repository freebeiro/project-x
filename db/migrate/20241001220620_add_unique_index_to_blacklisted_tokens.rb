# frozen_string_literal: true

# Adds a unique index to the token column in the blacklisted_tokens table
class AddUniqueIndexToBlacklistedTokens < ActiveRecord::Migration[7.1]
  # Adds a unique index to the token column in the blacklisted_tokens table
  def change
    add_index :blacklisted_tokens, :token, unique: true
  end
end
