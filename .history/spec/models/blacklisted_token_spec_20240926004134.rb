require 'rails_helper'

RSpec.describe BlacklistedToken, type: :model do
  it 'is valid with valid attributes' do
    blacklisted_token = BlacklistedToken.new(token: 'sample_token', expires_at: 1.day.from_now)
    expect(blacklisted_token).to be_valid
  end

  it 'is not valid without a token' do
    blacklisted_token = BlacklistedToken.new(expires_at: 1.day.from_now)
    expect(blacklisted_token).to_not be_valid
  end

  it 'is not valid without an expiration date' do
    blacklisted_token = BlacklistedToken.new(token: 'sample_token')
    expect(blacklisted_token).to_not be_valid
  end
end
