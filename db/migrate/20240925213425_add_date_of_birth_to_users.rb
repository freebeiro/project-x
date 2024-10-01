# frozen_string_literal: true

class AddDateOfBirthToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :date_of_birth, :date
  end
end
