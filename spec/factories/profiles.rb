# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    age { rand(18..65) }
    username { Faker::Internet.username }
    description { Faker::Lorem.paragraph }
    occupation { Faker::Job.title }
    user
  end
end
