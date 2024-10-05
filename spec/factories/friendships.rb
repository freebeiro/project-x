# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    user
    friend factory: %i[user]
    status { 'pending' }
  end
end
