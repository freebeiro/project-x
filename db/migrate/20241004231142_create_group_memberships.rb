# frozen_string_literal: true

# Creates the group_memberships table
class CreateGroupMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :group_memberships, %i[user_id group_id], unique: true
  end
end
