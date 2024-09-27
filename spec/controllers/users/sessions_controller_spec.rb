# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  let(:token) { JwtService.encode(user_id: user.id) }

  describe 'POST #create' do
    context 'with an invalid token' do
      let(:invalid_token) { 'invalid.token.here' }

      before do
        request.headers['Authorization'] = "Bearer #{invalid_token}"
      end

      it 'returns unauthorized status for invalid token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an invalid token message' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid token provided.')
      end
    end
    context 'with a malformed token' do
      let(:malformed_token) { 'malformed.token' }

      before do
        request.headers['Authorization'] = "Bearer #{malformed_token}"
      end

      it 'returns unauthorized status for malformed token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an invalid token message' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid token provided.')
      end
    end
    context 'with no token' do
      it 'logs the user in and returns success status' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:success)
      end

      it 'returns a JWT token in the response' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to include('token')
      end
    end
    context 'when already logged in' do
      before do
        valid_token = JwtService.encode(user_id: user.id)
        request.headers['Authorization'] = "Bearer #{valid_token}"
      end

      it 'returns bad request status' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an already logged in message' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You are already logged in.')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when token is valid' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'blacklists the token and returns success message' do
        expect(TokenBlacklistService).to receive(:blacklist).with(token).and_return(true)
        delete :destroy
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Logged out successfully')
      end
    end

    context 'when blacklisting fails' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        allow(TokenBlacklistService).to receive(:blacklist).and_return(false) # Simulate blacklist failure
      end

      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a no active session message' do
        delete :destroy
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('No active session')
      end
    end

    context 'when token is missing' do
      before do
        request.headers['Authorization'] = nil
      end

      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a no active session message' do
        delete :destroy
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('No active session')
      end
    end

    context 'when token is invalid' do
      let(:invalid_token) { 'invalid.token.here' }

      before do
        request.headers['Authorization'] = "Bearer #{invalid_token}"
        allow(TokenBlacklistService).to receive(:blacklist).and_return(false) # Simulate failure in token blacklisting
      end

      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an invalid token message' do
        delete :destroy
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('No active session')
      end
    end
  end
end
