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

  # Include FactoryBot syntax methods for cleaner calls
  include FactoryBot::Syntax::Methods

  describe 'POST #create' do
    # Use FactoryBot to generate valid attributes, ensuring uniqueness
    let(:profile_attrs) { attributes_for(:profile).except(:user) } # Exclude user association
    let(:user_attrs) { attributes_for(:user) }
    let(:valid_attributes) do
      {
        user: user_attrs.merge(profile_attributes: profile_attrs)
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

      # Split into two tests to avoid multiple expectations
      it 'returns profile data in response' do
        post :create, params: valid_attributes
        expect(response.parsed_body['data']['profile']).to be_present
      end

      it 'returns correct profile username in response' do
        post :create, params: valid_attributes
        expect(response.parsed_body['data']['profile']['username']).to eq(profile_attrs[:username])
      end

      it 'returns a JWT token' do
        post :create, params: valid_attributes
        expect(response.parsed_body['data']).to include('token')
      end
    end

    # This context tests user creation without profile data (optional)
    context 'with valid user parameters only' do
      # Use FactoryBot for user attributes here too for consistency
      let(:user_only_attributes) { { user: attributes_for(:user) } }

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
