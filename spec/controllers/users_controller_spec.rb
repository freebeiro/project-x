require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    authenticate_user(user)
  end

  describe 'GET #search' do
    context 'when user exists' do
      it 'returns user information' do
        get :search, params: { username: user.profile.username }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['email']).to eq(user.email)
        expect(json_response['username']).to eq(user.profile.username)
      end
    end

    context 'when user does not exist' do
      it 'returns a not found error' do
        get :search, params: { username: 'nonexistent' }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('User not found')
      end
    end
  end
end
