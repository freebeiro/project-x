# frozen_string_literal: true

# Migration for adding date_of_birth to users table
class AddDateOfBirthToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :date_of_birth, :date
  end
end
