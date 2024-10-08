# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before do
    authenticate_user(user)
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new friendship' do
        expect do
          post :create, params: { friendship: { friend_username: friend.profile.username } }
        end.to change(Friendship, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: { friendship: { friend_username: friend.profile.username } }
        expect(response).to have_http_status(:created)
      end

      it 'returns a success message' do
        post :create, params: { friendship: { friend_username: friend.profile.username } }
        expect(response.parsed_body['message']).to eq('Friendship request sent successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns a not found status for non-existent user' do
        post :create, params: { friendship: { friend_username: 'nonexistent' } }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found error message for non-existent user' do
        post :create, params: { friendship: { friend_username: 'nonexistent' } }
        expect(response.parsed_body['error']).to eq('User not found')
      end

      it 'returns unprocessable entity status for invalid friendship' do
        friendship = build(:friendship) # Use a factory to build a friendship instance
        allow(friendship).to receive_messages(save: false, errors: double(full_messages: ['Invalid friendship']))
        allow(Friendship).to receive(:new).and_return(friendship)

        post :create, params: { friendship: { friend_username: friend.profile.username } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages for invalid friendship' do
        allow_any_instance_of(Friendship).to receive(:save).and_return(false)
        allow_any_instance_of(Friendship).to receive(:errors).and_return(double(full_messages: ['Invalid friendship']))

        post :create, params: { friendship: { friend_username: friend.profile.username } }
        expect(response.parsed_body['errors']).to eq(['Invalid friendship'])
      end
    end
  end

  describe 'PUT #accept' do
    context 'with valid parameters' do
      let!(:friendship) { create(:friendship, user: friend, friend: user, status: 'pending') }

      it 'returns status ok' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response.parsed_body['message']).to eq('Friendship accepted successfully')
      end

      it 'accepts accepted status' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(friendship.reload.status).to eq('accepted')
      end
    end

    context 'with invalid parameters' do
      it 'returns a not found error for non-existent friendship' do
        Friendship.where(friend: user, status: 'pending').destroy_all
        Friendship.where(user:, status: 'pending').destroy_all

        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns Friendship request not found' do
        Friendship.where(friend: user, status: 'pending').destroy_all
        Friendship.where(user:, status: 'pending').destroy_all

        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response.parsed_body['error']).to eq('Friendship request not found')
      end

      it 'returns unprocessable entity' do
        friendship = create(:friendship, user: friend, friend: user, status: 'pending')
        allow(Friendship).to receive(:find_by).and_return(friendship)
        allow(friendship).to receive_messages(update: false, errors: double(full_messages: ['Invalid update']))

        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error Invalid update' do
        friendship = create(:friendship, user: friend, friend: user, status: 'pending')
        allow(Friendship).to receive(:find_by).and_return(friendship)
        allow(friendship).to receive_messages(update: false, errors: double(full_messages: ['Invalid update']))

        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response.parsed_body['errors']).to eq(['Invalid update'])
      end
    end
  end
end
