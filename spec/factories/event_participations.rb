# frozen_string_literal: true

FactoryBot.define do
  factory :event_participation do
    status { EventParticipation::STATUS_ATTENDING }
    user
    event
  end
end
