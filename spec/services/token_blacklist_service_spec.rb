# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenBlacklistService do
  describe '.blacklist' do
    it 'creates a new BlacklistedToken' do
      token = 'sample_token'
      expect do
        described_class.blacklist(token)
      end.to change(BlacklistedToken, :count).by(1)
    end

    it 'sets the correct token value' do
      token = 'sample_token'
      described_class.blacklist(token)
      expect(BlacklistedToken.last.token).to eq(token)
    end

    it 'sets the expiration time to approximately 24 hours from now' do
      described_class.blacklist('sample_token')
      expect(BlacklistedToken.last.expires_at).to be_within(1.second).of(24.hours.from_now)
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
