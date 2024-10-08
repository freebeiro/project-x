# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :authenticate_user_from_token!

    def index
      render json: { message: 'Authenticated' }
    end
  end

  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  let(:token) { JwtService.encode(user_id: user.id) }

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  describe '#authenticate_user_from_token!' do
    context 'with a valid token' do
      it 'authenticates the user' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'returns the correct message' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        expect(response.parsed_body['message']).to eq('Authenticated')
      end
    end

    context 'with an invalid token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :index
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns correct status code in JSON response' do
        expect(response.parsed_body['status']).to eq(401)
      end

      it 'returns correct error message in JSON response' do
        expect(response.parsed_body['message']).to eq('Unauthorized')
      end
    end

    context 'without a token' do
      before do
        get :index
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns correct status code in JSON response' do
        expect(response.parsed_body['status']).to eq(401)
      end

      it 'returns correct error message in JSON response' do
        expect(response.parsed_body['message']).to eq('Unauthorized')
      end
    end
  end
end
