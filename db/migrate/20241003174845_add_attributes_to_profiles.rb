# frozen_string_literal: true

# AddAttributesToProfiles
# This migration adds new attributes to the profiles table and ensures proper column setup
class AddAttributesToProfiles < ActiveRecord::Migration[6.1]
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def change
    # Add new columns
    add_column :profiles, :first_name, :string unless column_exists?(:profiles, :first_name)
    add_column :profiles, :last_name, :string unless column_exists?(:profiles, :last_name)
    add_column :profiles, :username, :string unless column_exists?(:profiles, :username)
    add_column :profiles, :occupation, :string unless column_exists?(:profiles, :occupation)
    add_column :profiles, :age, :integer unless column_exists?(:profiles, :age)

    # Rename existing 'name' column to 'first_name' if it exists
    if column_exists?(:profiles, :name) && !column_exists?(:profiles, :first_name)
      rename_column :profiles, :name, :first_name
    end

    # Add index for username
    add_index :profiles, :username, unique: true, if_not_exists: true

    # Ensure description column exists
    add_column :profiles, :description, :text unless column_exists?(:profiles, :description)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
