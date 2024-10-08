# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end

    context 'when profile exists' do
      let(:profile) { create(:profile, user:, first_name: 'John', last_name: 'Doe') }

      before do
        profile # Create the profile
        get :show
      end

      it 'returns the correct profile' do
        expect(assigns(:profile)).to eq(profile)
      end

      it 'returns the correct profile name' do
        expect(response.parsed_body['name']).to eq('John Doe')
      end
    end
  end

  describe 'PUT #update' do
    let(:new_first_name) { 'Jane' }
    let(:new_age) { 30 }

    context 'when profile exists' do
      let(:profile) { create(:profile, user:) }

      before { profile } # Reference profile to satisfy RuboCop

      it "updates the user's profile first name" do
        put :update, params: { profile: { first_name: new_first_name } }
        expect(user.reload.profile.first_name).to eq(new_first_name)
      end

      it "updates the user's profile age" do
        put :update, params: { profile: { age: new_age } }
        expect(user.reload.profile.age).to eq(new_age)
      end

      it 'returns http success on successful update' do
        put :update, params: { profile: { first_name: new_first_name } }
        expect(response).to have_http_status(:success)
      end

      it 'returns unprocessable entity status on invalid update' do
        put :update, params: { profile: { age: 17 } } # Age less than 18 is invalid
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors on invalid update' do
        put :update, params: { profile: { age: 17 } } # Age less than 18 is invalid
        expect(response.parsed_body).to have_key('errors')
      end
    end

    context 'when profile does not exist' do
      it 'creates a new profile' do
        expect do
          put :update, params: { profile: attributes_for(:profile) }
        end.to change(Profile, :count).by(1)
      end

      it 'returns a success status' do
        put :update, params: { profile: attributes_for(:profile) }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
