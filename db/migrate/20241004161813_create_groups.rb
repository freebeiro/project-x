# frozen_string_literal: true

# CreateGroups creates the groups table
class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :description
      t.string :privacy, default: 'public'
      t.integer :member_limit
      t.references :admin, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
