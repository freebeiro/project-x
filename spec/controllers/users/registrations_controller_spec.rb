# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  let(:request) { ActionDispatch::TestRequest.create }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          date_of_birth: 20.years.ago.to_date
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns a JWT token' do
        post :create, params: valid_attributes
        expect(response.parsed_body['data']).to include('token')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { user: { email: 'invalid' } } }

      it 'does not create a new User' do
        expect do
          post :create, params: invalid_attributes
        end.not_to change(User, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error message' do
        post :create, params: invalid_attributes
        expect(response.parsed_body['status']).to include('message')
      end
    end
  end
end
