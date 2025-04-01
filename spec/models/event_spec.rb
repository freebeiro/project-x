# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { create(:user) }

  it 'is valid with valid attributes' do
    event = build(:event, organizer: user)
    expect(event).to be_valid
  end

  it 'requires a name' do
    event = build(:event, name: nil, organizer: user)
    expect(event).not_to be_valid
  end

  it 'validates start time before end time' do
    event = build(:event, start_time: 1.day.from_now, end_time: 2.days.ago, organizer: user)
    expect(event).not_to be_valid
  end

  describe '#at_capacity?' do
    let(:event) { create(:event, :full, organizer: user) }

    it 'returns true when event is full' do
      create(:event_participation, event:)
      expect(event.at_capacity?).to be true
    end

    it 'returns false when under capacity' do
      expect(event.at_capacity?).to be false
    end
  end

  describe 'associations' do
    it 'has many event_participations' do
      event = create(:event, organizer: user)
      create(:event_participation, event:)
      expect(event.event_participations.count).to eq(1)
    end

    it 'has many participants through event_participations' do
      event = create(:event, organizer: user)
      participant = create(:user)
      create(:event_participation, event:, user: participant)
      expect(event.participants).to include(participant)
    end

    it 'belongs to an organizer' do
      event = create(:event, organizer: user)
      expect(event.organizer).to eq(user)
    end
  end

  describe 'validations' do
    it 'validates capacity is positive' do
      event = build(:event, capacity: 0, organizer: user)
      expect(event).not_to be_valid
    end
  end
end
