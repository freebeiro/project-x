# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { 'MyText' }
    user { nil }
    group { nil }
    event { nil }
  end
end
