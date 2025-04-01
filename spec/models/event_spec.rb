# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { create(:user) }
  let(:group) { create(:group) } # Add group for association

  it 'is valid with valid attributes' do
    # Add group association
    event = build(:event, organizer: user, group:)
    expect(event).to be_valid
  end

  it 'requires a name' do
    # Add group association
    event = build(:event, name: nil, organizer: user, group:)
    expect(event).not_to be_valid
  end

  it 'validates start time before end time' do
    # Add group association
    event = build(:event, start_time: 1.day.from_now, end_time: 2.days.ago, organizer: user, group:)
    expect(event).not_to be_valid
  end

  describe '#at_capacity?' do
    # Add group association
    let(:event) { create(:event, :full, organizer: user, group:) }

    it 'returns true when event is full' do
      create(:event_participation, event:, user: create(:user)) # Need user for participation
      expect(event.at_capacity?).to be true
    end

    it 'returns false when under capacity' do
      expect(event.at_capacity?).to be false
    end
  end

  describe 'associations' do
    # Add group association
    let(:event) { create(:event, organizer: user, group:) }

    it 'has many event_participations' do
      create(:event_participation, event:, user: create(:user)) # Need user
      expect(event.event_participations.count).to eq(1)
    end

    it 'has many participants through event_participations' do
      participant = create(:user)
      create(:event_participation, event:, user: participant)
      expect(event.participants).to include(participant)
    end

    it 'belongs to an organizer' do
      expect(event.organizer).to eq(user)
    end

    # Add test for group association
    it 'belongs to a group' do
      expect(event.group).to eq(group)
    end
  end

  describe 'validations' do
    it 'validates capacity is positive' do
      # Add group association
      event = build(:event, capacity: 0, organizer: user, group:)
      expect(event).not_to be_valid
    end

    # Add test for group presence validation (implicit via belongs_to)
    context 'when group is missing' do
      let(:event_without_group) { build(:event, organizer: user, group: nil) }

      it 'is not valid' do
        expect(event_without_group).not_to be_valid
      end

      it 'has an error on group' do
        event_without_group.valid? # Trigger validation
        expect(event_without_group.errors[:group]).to include('must exist')
      end
    end
  end
end
