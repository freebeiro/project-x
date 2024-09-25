require 'rails_helper'

RSpec.describe BlacklistedToken, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      blacklisted_token = BlacklistedToken.new(token: 'valid_token', expires_at: 1.day.from_now)
      expect(blacklisted_token).to be_valid
    end

    it 'is not valid without a token' do
      blacklisted_token = BlacklistedToken.new(expires_at: 1.day.from_now)
      expect(blacklisted_token).to_not be_valid
      expect(blacklisted_token.errors[:token]).to include("can't be blank")
    end

    it 'is not valid without an expiration date' do
      blacklisted_token = BlacklistedToken.new(token: 'valid_token')
      expect(blacklisted_token).to_not be_valid
      expect(blacklisted_token.errors[:expires_at]).to include("can't be blank")
    end

    it 'is not valid with a duplicate token' do
      BlacklistedToken.create(token: 'duplicate_token', expires_at: 1.day.from_now)
      blacklisted_token = BlacklistedToken.new(token: 'duplicate_token', expires_at: 2.days.from_now)
      expect(blacklisted_token).to_not be_valid
      expect(blacklisted_token.errors[:token]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    it 'returns only active blacklisted tokens' do
      active_token = BlacklistedToken.create(token: 'active_token', expires_at: 1.day.from_now)
      expired_token = BlacklistedToken.create(token: 'expired_token', expires_at: 1.day.ago)

      expect(BlacklistedToken.active).to include(active_token)
      expect(BlacklistedToken.active).not_to include(expired_token)
    end
  end
end
