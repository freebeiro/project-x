# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventParticipation, type: :model do
  let(:user) { create(:user) }
  let(:event) { create(:event, organizer: user) }

  it 'is valid with user and event' do
    participation = build(:event_participation, user:, event:)
    expect(participation).to be_valid
  end

  it 'requires a user' do
    participation = build(:event_participation, user: nil, event:)
    expect(participation).not_to be_valid
  end

  it 'requires an event' do
    participation = build(:event_participation, user:, event: nil)
    expect(participation).not_to be_valid
  end

  it 'prevents duplicate participations' do
    create(:event_participation, user:, event:)
    participation = build(:event_participation, user:, event:)
    expect(participation).not_to be_valid
  end
end
