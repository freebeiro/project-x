require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          date_of_birth: 20.years.ago
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end

      it 'returns a JWT token' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']).to include('token')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect do
          post :create, params: { user: { email: 'invalid' } }
        end.to change(User, :count).by(0)
      end

      it 'returns an error message' do
        post :create, params: { user: { email: 'invalid' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['status']).to include('message')
      end
    end
  end
end
