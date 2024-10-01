# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  let(:token) { JwtService.encode(user_id: user.id) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    shared_examples 'returns unauthorized status' do
      it 'returns unauthorized status' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    shared_examples 'returns invalid token message' do
      it 'returns an invalid token message' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response.parsed_body['error']).to eq('Invalid token provided.')
      end
    end

    context 'with an invalid token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid.token.here'
      end

      include_examples 'returns unauthorized status'
      include_examples 'returns invalid token message'
    end

    context 'with a malformed token' do
      before do
        request.headers['Authorization'] = 'Bearer malformed.token'
      end

      include_examples 'returns unauthorized status'
      include_examples 'returns invalid token message'
    end

    context 'with no token' do
      it 'logs the user in and returns success status' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:success)
      end

      it 'returns a JWT token in the response' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response.parsed_body['data']).to include('token')
      end
    end

    context 'when already logged in' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns bad request status' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an already logged in message' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response.parsed_body['error']).to eq('You are already logged in.')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when token is valid' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        allow(TokenBlacklistService).to receive(:blacklist).with(token).and_return(true)
      end

      it 'blacklists the token' do
        expect(TokenBlacklistService).to receive(:blacklist).with(token)
        delete :destroy
      end

      it 'returns success status' do
        delete :destroy
        expect(response).to have_http_status(:success)
      end

      it 'returns success message' do
        delete :destroy
        expect(response.parsed_body['message']).to eq('Logged out successfully')
      end
    end

    context 'when blacklisting fails' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        allow(TokenBlacklistService).to receive(:blacklist).and_return(false)
      end

      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a no active session message' do
        delete :destroy
        expect(response.parsed_body['message']).to eq('No active session')
      end
    end

    context 'when token is missing' do
      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a no active session message' do
        delete :destroy
        expect(response.parsed_body['message']).to eq('No active session')
      end
    end

    context 'when token is invalid' do
      before do
        request.headers['Authorization'] = 'Bearer invalid.token.here'
      end

      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a no active session message' do
        delete :destroy
        expect(response.parsed_body['message']).to eq('No active session')
      end
    end
  end
end
