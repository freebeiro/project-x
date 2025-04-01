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

    # Split multi-expectation tests
    context 'when content is nil' do
      before { message.content = nil }

      it { is_expected.not_to be_valid }

      it 'has a blank error on content' do
        message.valid?
        expect(message.errors[:content]).to include("can't be blank")
      end
    end

    context 'when content is empty' do
      before { message.content = '' }

      it { is_expected.not_to be_valid }

      it 'has a blank error on content' do
        message.valid?
        expect(message.errors[:content]).to include("can't be blank")
      end
    end

    context 'when user is missing' do
      before { message.user = nil }

      it { is_expected.not_to be_valid }

      it 'has an error on user' do
        message.valid?
        expect(message.errors[:user]).to include('must exist')
      end
    end

    context 'when group is missing' do
      before { message.group = nil }

      it { is_expected.not_to be_valid }

      it 'has an error on group' do
        message.valid?
        expect(message.errors[:group]).to include('must exist')
      end
    end

    context 'when event is missing' do
      before { message.event = nil }

      it { is_expected.not_to be_valid }

      it 'has an error on event' do
        message.valid?
        expect(message.errors[:event]).to include('must exist')
      end
    end
  end
end
