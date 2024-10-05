# frozen_string_literal: true

FactoryBot.define do
  factory :group_membership do
    user
    group
  end
end
