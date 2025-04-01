# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  # Using FactoryBot to create instances for association tests
  subject(:message) do
    # Build (don't save) a message instance for validation tests
    build(:message, user:, group:, event:, content: 'Hello there!')
  end

  let(:user) { create(:user) }
  let(:group) { create(:group) }
  # Add group association to event creation
  let(:event) { create(:event, organizer: user, group:) }

  describe 'associations' do
    # Test that Message belongs_to user, group, and event
    # Assumes shoulda-matchers gem is installed
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:event) }
  end

  describe 'validations' do
    # Test content presence validation
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_least(1) }

    it 'is valid with valid attributes' do
      expect(message).to be_valid
    end

    it 'is not valid without content' do
      message.content = nil
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it 'is not valid with empty content' do
      message.content = ''
      expect(message).not_to be_valid
      # NOTE: presence validation covers empty strings, length validation might add another error
      expect(message.errors[:content]).to include("can't be blank")
    end

    # Test foreign key presence (implicitly tested by belongs_to, but can be explicit)
    it 'is not valid without a user' do
      message.user = nil
      expect(message).not_to be_valid
      expect(message.errors[:user]).to include('must exist')
    end

    it 'is not valid without a group' do
      message.group = nil
      expect(message).not_to be_valid
      expect(message.errors[:group]).to include('must exist')
    end

    it 'is not valid without an event' do
      message.event = nil
      expect(message).not_to be_valid
      expect(message.errors[:event]).to include('must exist')
    end
  end
end
