# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    authenticate_user(user)
  end

  describe 'GET #search' do
    context 'when user exists' do
      it 'returns status ok' do
        get :search, params: { username: user.profile.username }
        expect(response).to have_http_status(:ok)
      end

      it 'returns user id' do
        get :search, params: { username: user.profile.username }
        json_response = response.parsed_body
        expect(json_response['id']).to eq(user.id)
      end

      it 'returns user email' do
        get :search, params: { username: user.profile.username }
        json_response = response.parsed_body
        expect(json_response['email']).to eq(user.email)
      end

      it 'returns user username' do
        get :search, params: { username: user.profile.username }
        json_response = response.parsed_body
        expect(json_response['username']).to eq(user.profile.username)
      end
    end

    context 'when user does not exist' do
      it 'returns a not found error' do
        get :search, params: { username: 'nonexistent' }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns User not found' do
        get :search, params: { username: 'nonexistent' }
        expect(response.parsed_body['error']).to eq('User not found')
      end
    end
  end
end
