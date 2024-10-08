# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    date_of_birth { 20.years.ago }

    after(:create) do |user|
      create(:profile, user:)
    end
  end
end
