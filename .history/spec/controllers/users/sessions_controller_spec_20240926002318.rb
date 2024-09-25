# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let!(:user) { User.create(email: 'test@example.com', password: 'password', date_of_birth: 20.years.ago) }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post :create, params: { user: { email: 'test@example.com', password: 'password' } }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['data']).to include('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns an error' do
        post :create, params: { user: { email: 'test@example.com', password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { User.create(email: 'test@example.com', password: 'password', date_of_birth: 20.years.ago) }

    it 'returns success message' do
      request.headers['Authorization'] = 'Bearer mock_token'
      delete :destroy
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end
  end
end
