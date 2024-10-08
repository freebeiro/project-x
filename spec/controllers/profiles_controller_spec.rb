# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:non_friend) { create(:user) }

  before do
    allow(controller).to receive(:authenticate_user_from_token!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #show' do
    context 'when viewing own profile' do
      it 'returns http success' do
        get :show
        expect(response).to have_http_status(:ok)
      end

      it 'includes first_name in the response' do
        get :show
        expect(JSON.parse(response.body)['data']).to include('first_name')
      end

      it 'includes last_name in the response' do
        get :show
        expect(JSON.parse(response.body)['data']).to include('last_name')
      end
    end

    context 'when viewing a friend\'s profile' do
      let(:friend_profile) { friend.profile }

      before do
        create(:friendship, :accepted, user:, friend:)
      end

      it 'returns http success' do
        get :show, params: { id: friend_profile.id }
        expect(response).to have_http_status(:ok)
      end

      it 'includes first_name in the response' do
        get :show, params: { id: friend_profile.id }
        expect(JSON.parse(response.body)['data']).to include('first_name')
      end

      it 'includes last_name in the response' do
        get :show, params: { id: friend_profile.id }
        expect(JSON.parse(response.body)['data']).to include('last_name')
      end
    end

    context 'when viewing a non-friend\'s profile' do
      let(:non_friend_profile) { non_friend.profile }

      it 'returns http success' do
        get :show, params: { id: non_friend_profile.id }
        expect(response).to have_http_status(:ok)
      end

      it 'includes username in the response' do
        get :show, params: { id: non_friend_profile.id }
        expect(JSON.parse(response.body)['data']).to include('username')
      end

      it 'does not include first_name in the response' do
        get :show, params: { id: non_friend_profile.id }
        expect(JSON.parse(response.body)['data']).not_to include('first_name')
      end

      it 'does not include last_name in the response' do
        get :show, params: { id: non_friend_profile.id }
        expect(JSON.parse(response.body)['data']).not_to include('last_name')
      end
    end

    context 'when profile does not exist' do
      it 'returns not found status' do
        get :show, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end

      it 'includes error message in the response' do
        get :show, params: { id: 999 }
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) { { first_name: 'Updated', last_name: 'Name' } }

    before do
      user.create_profile(first_name: 'Original', last_name: 'Name') unless user.profile
    end

    it 'returns http success' do
      put :update, params: { profile: new_attributes }
      expect(response).to have_http_status(:ok)
    end

    it 'updates the first_name' do
      put :update, params: { profile: new_attributes }
      user.profile.reload
      expect(user.profile.first_name).to eq('Updated')
    end

    it 'updates the last_name' do
      put :update, params: { profile: new_attributes }
      user.profile.reload
      expect(user.profile.last_name).to eq('Name')
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { { age: 'invalid' } }

      it 'returns unprocessable entity status' do
        put :update, params: { profile: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
