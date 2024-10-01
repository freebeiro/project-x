# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenBlacklistService do
  describe '.blacklist' do
    it 'creates a new BlacklistedToken with the given token and expiry' do
      token = 'sample_token'
      expect do
        described_class.blacklist(token)
      end.to change(BlacklistedToken, :count).by(1)

      blacklisted_token = BlacklistedToken.last
      expect(blacklisted_token.token).to eq(token)
      expect(blacklisted_token.expires_at).to be_within(1.second).of(24.hours.from_now)
    end
  end

  describe '.blacklisted?' do
    it 'returns true for a blacklisted token' do
      token = 'blacklisted_token'
      described_class.blacklist(token)
      expect(described_class.blacklisted?(token)).to be true
    end

    it 'returns false for a non-blacklisted token' do
      token = 'non_blacklisted_token'
      expect(described_class.blacklisted?(token)).to be false
    end
  end
end
