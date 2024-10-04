# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonWebToken do
  describe '.encode' do
    it 'encodes a payload into a JWT token' do
      payload = { user_id: 1 }
      token = described_class.encode(payload)
      expect(token).to be_a(String)
    end

    it 'sets an expiration time' do
      payload = { user_id: 1 }
      exp = 1.hour.from_now
      token = described_class.encode(payload, exp)
      decoded_payload = JWT.decode(token, described_class::SECRET_KEY)[0]
      expect(decoded_payload['exp']).to eq(exp.to_i)
    end
  end

  describe '.decode' do
    it 'decodes a valid JWT token' do
      payload = { user_id: 1 }
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(payload[:user_id])
    end

    it 'returns a HashWithIndifferentAccess' do
      payload = { user_id: 1 }
      token = described_class.encode(payload)
      decoded = described_class.decode(token)
      expect(decoded).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end
  end
end
