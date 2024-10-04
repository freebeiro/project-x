# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    name { 'Test Group' }
    description { 'A test group' }
    privacy { 'public' }
    member_limit { 10 }
    admin factory: %i[user]
  end
end
