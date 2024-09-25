# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe 'POST #create' do
    let!(:user) { User.create(email: 'test@example.com', password: 'password', date_of_birth: 20.years.ago) }

    context 'with valid credentials' do
      it 'returns a JWT token' do
        post :create, params: { user: { email: 'test@example.com', password: 'password' } }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns an error' do
        post :create, params: { user: { email: 'test@example.com', password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # Add more tests for other actions...
end
