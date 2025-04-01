# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  # No need for let(:request) as @request is available in controller specs
  # let(:request) { ActionDispatch::TestRequest.create }

  before do
    # IMPORTANT: Set request env for Devise controller specs
    # rubocop:disable RSpec/InstanceVariable
    @request.env['devise.mapping'] = Devise.mappings[:user]
    # rubocop:enable RSpec/InstanceVariable
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          date_of_birth: 20.years.ago.to_date,
          # Correctly nest profile_attributes under user
          profile_attributes: {
            first_name: 'John',
            last_name: 'Doe',
            age: 25,
            username: 'johndoe',
            description: 'Test user',
            occupation: 'Developer'
          }
        }
      }
    end

    # This context specifically tests profile creation along with user
    context 'with valid parameters including profile' do
      it 'creates a new User' do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
      end

      it 'creates a new Profile' do
        expect do
          post :create, params: valid_attributes
        end.to change(Profile, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns profile data in response' do
        post :create, params: valid_attributes
        expect(response.parsed_body['data']['profile']).to include(
          'first_name' => 'John',
          'last_name' => 'Doe'
          # Add other profile fields if needed
        )
      end

      it 'returns a JWT token' do
        post :create, params: valid_attributes
        expect(response.parsed_body['data']).to include('token')
      end
    end

    # This context tests user creation without profile data (optional)
    context 'with valid user parameters only' do
      let(:user_only_attributes) do
        {
          user: {
            email: 'test2@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            date_of_birth: 25.years.ago.to_date
          }
        }
      end

      it 'creates a new User' do
        expect do
          post :create, params: user_only_attributes
        end.to change(User, :count).by(1)
      end

      it 'does not create a new Profile' do
        expect do
          post :create, params: user_only_attributes
        end.not_to change(Profile, :count)
      end

      it 'returns created status' do
        post :create, params: user_only_attributes
        expect(response).to have_http_status(:created)
      end

      it 'returns a JWT token' do
        post :create, params: user_only_attributes
        expect(response.parsed_body['data']).to include('token')
      end

      it 'returns null profile data' do
        post :create, params: user_only_attributes
        expect(response.parsed_body['data']['profile']).to be_nil
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { user: { email: 'invalid' } } }

      it 'does not create a new User' do
        expect do
          post :create, params: invalid_attributes
        end.not_to change(User, :count)
      end

      it 'does not create a new Profile' do
        expect do
          post :create, params: invalid_attributes
        end.not_to change(Profile, :count)
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
