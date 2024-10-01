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
        json_response = response.parsed_body
        expect(json_response['message']).to eq('Authenticated')
      end
    end

    context 'with an invalid token' do
      it 'returns unauthorized' do
        request.headers['Authorization'] = 'Bearer invalid_token'
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response['status']).to eq(401)
        expect(json_response['message']).to eq('Unauthorized')
      end
    end

    context 'without a token' do
      it 'returns unauthorized' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response['status']).to eq(401)
        expect(json_response['message']).to eq('Unauthorized')
      end
    end
  end
end
