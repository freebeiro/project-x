require 'rails_helper'

RSpec.describe TokenBlacklistService do
  let(:token) { SecureRandom.hex(10) } # Generates a unique token for each test

  before(:each) do
    BlacklistedToken.delete_all
  end

  describe '.blacklist' do
    it 'creates a new BlacklistedToken with the given token and expiry' do
      expect {
        @blacklisted_token = TokenBlacklistService.blacklist(token)
        unless @blacklisted_token.persisted?
          puts @blacklisted_token.errors.full_messages
        end
      }.to change(BlacklistedToken, :count).by(1)
  
      blacklisted_token = BlacklistedToken.last
      expect(blacklisted_token.token).to eq(token)
      expect(blacklisted_token.expires_at).to be_within(5.seconds).of(24.hours.from_now)
    end
  end
  

  describe '.blacklisted?' do
    context 'when the token is blacklisted' do
      before do
        TokenBlacklistService.blacklist(token)
      end

      it 'returns true' do
        expect(TokenBlacklistService.blacklisted?(token)).to be true
      end
    end

    context 'when the token is not blacklisted' do
      it 'returns false' do
        expect(TokenBlacklistService.blacklisted?(token)).to be false
      end
    end
  end
end
