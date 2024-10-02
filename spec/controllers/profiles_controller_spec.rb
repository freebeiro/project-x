# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JwtService.encode(user_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end

    it 'returns the current user\'s profile' do
      create(:profile, user:, name: 'John Doe')
      get :show
      expect(response.parsed_body['name']).to eq('John Doe')
    end
  end

  describe 'PUT #update' do
    let(:new_name) { 'Jane Doe' }
    let(:new_age) { 25 }

    before do
      put :update, params: { profile: { name: new_name, age: new_age } }
      user.reload
    end

    it 'updates the user\'s profile name' do
      expect(user.profile.name).to eq(new_name)
    end

    it 'updates the user\'s profile age' do
      expect(user.profile.age).to eq(new_age)
    end

    it 'returns http success on successful update' do
      expect(response).to have_http_status(:success)
    end

    context 'with invalid parameters' do
      it 'returns errors on failed update' do
        put :update, params: { profile: { age: 17 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'includes error messages on failed update' do
        put :update, params: { profile: { age: 17 } }
        expect(response.parsed_body['errors']).to include('Age must be greater than or equal to 18')
      end
    end
  end
end
