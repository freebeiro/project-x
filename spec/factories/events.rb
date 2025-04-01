# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { 'Test Event' }
    description { 'Test Description' }
    location { 'Virtual' }
    start_time { 1.day.from_now }
    end_time { 2.days.from_now }
    capacity { 10 }
    organizer factory: %i[user]

    trait :full do
      capacity { 1 }
    end
  end
end
