# spec/services/jwt_service_spec.rb
require 'rails_helper'

RSpec.describe JwtService, type: :service do
  describe '.encode' do
    it 'encodes a payload into a JWT token' do
      payload = { user_id: 1 }
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').size).to eq(3) # JWT tokens have three parts
    end
  end

  describe '.decode' do
    context 'with a valid token' do
      it 'returns the decoded payload' do
        payload = { 'user_id' => 1 }
        token = JwtService.encode(payload)
        decoded = JwtService.decode(token)
        expect(decoded).to include('user_id' => 1)
      end
    end

    context 'with an invalid token' do
      it 'returns nil' do
        invalid_token = 'invalid.token.here'
        decoded = JwtService.decode(invalid_token)
        expect(decoded).to be_nil
      end
    end

    context 'with an expired token' do
      it 'returns nil' do
        payload = { 'user_id' => 1 }
        # Correct: Passing exp as a positional argument
        token = JwtService.encode(payload, 1.second.ago)
        decoded = JwtService.decode(token)
        expect(decoded).to be_nil
      end
    end


    context 'when JWT.decode raises JWT::DecodeError' do
      it 'returns nil' do
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)
        decoded = JwtService.decode('any.token.here')
        expect(decoded).to be_nil
      end
    end

    context 'when JWT.decode raises JWT::ExpiredSignature' do
      it 'returns nil' do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature)
        decoded = JwtService.decode('any.token.here')
        expect(decoded).to be_nil
      end
    end
  end
end
