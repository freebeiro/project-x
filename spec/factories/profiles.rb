# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    name { Faker::Name.name }
    age { rand(18..80) }
    description { Faker::Lorem.paragraph }
    user
  end
end
