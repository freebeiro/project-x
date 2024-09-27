# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  let(:token) { JwtService.encode(user_id: user.id) }

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'returns a successful response' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:success)
      end

      it 'returns a JWT token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to include('token')
      end

      it 'returns a success message' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to eq('Logged in successfully.')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post :create, params: { user: { email: user.email, password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        post :create, params: { user: { email: user.email, password: 'wrong_password' } }
        expect(response.body).to eq('Invalid Email or password.')
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
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You are already logged in.')
      end
    end

    context 'with an invalid token' do
      let(:invalid_token) { 'invalid.token.here' }

      before do
        request.headers['Authorization'] = "Bearer #{invalid_token}"
      end

      it 'returns bad request status for invalid token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an already logged in message for invalid token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You are already logged in.')
      end
    end
    context 'with a malformed token' do
      let(:malformed_token) { 'malformed.token.without.correct.structure' }

      before do
        request.headers['Authorization'] = "Bearer #{malformed_token}"
      end

      it 'returns bad request status for malformed token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an already logged in message for malformed token' do
        post :create, params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You are already logged in.')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      request.headers['Authorization'] = "Bearer #{token}"
    end

    it 'blacklists the token and returns success message' do
      expect(TokenBlacklistService).to receive(:blacklist).with(token)
      delete :destroy
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Logged out successfully')
    end

    context 'when token is missing' do
      before { request.headers['Authorization'] = nil }

      it 'returns unauthorized status' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
