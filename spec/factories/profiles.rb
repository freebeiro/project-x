# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    first_name { 'John' }
    last_name { 'Doe' }
    age { 25 }
    username { Faker::Internet.unique.username }
    description { 'A software developer' }
    occupation { 'Developer' }
    user
  end
end
