# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:non_friend) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    create(:friendship, user:, friend:, status: 'accepted')
  end

  describe 'GET #show' do
    context 'when viewing own profile' do
      it 'returns full profile details' do
        get :show, params: { id: profile.id }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['data']).to include('username', 'photo_url', 'first_name', 'last_name')
      end
    end

    context 'when viewing a friend\'s profile' do
      let(:friend_profile) { create(:profile, user: friend) }

      it 'returns full profile details' do
        get :show, params: { id: friend_profile.id }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['data']).to include('username', 'photo_url', 'first_name', 'last_name')
      end
    end

    context 'when viewing a non-friend\'s profile' do
      let(:non_friend_profile) { create(:profile, user: non_friend) }

      it 'returns limited profile details' do
        get :show, params: { id: non_friend_profile.id }
        expect(response).to have_http_status(:ok)
        parsed_response = response.parsed_body['data']
        expect(parsed_response).to include('username', 'photo_url')
        expect(parsed_response).not_to include('first_name', 'last_name')
      end
    end

    context 'when profile does not exist' do
      it 'returns a not found error' do
        get :show, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_key('error')
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
