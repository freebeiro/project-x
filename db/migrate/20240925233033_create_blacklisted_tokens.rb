# frozen_string_literal: true

# Migration for creating blacklisted_tokens table
class CreateBlacklistedTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
