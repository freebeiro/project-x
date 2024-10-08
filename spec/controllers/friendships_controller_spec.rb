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

      it 'returns a success message' do
        post :create, params: { friendship: { friend_username: friend.profile.username } }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Friendship request sent successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns a not found error for non-existent user' do
        post :create, params: { friendship: { friend_username: 'nonexistent' } }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('User not found')
      end

      it 'returns unprocessable entity for invalid friendship' do
        allow_any_instance_of(Friendship).to receive(:save).and_return(false)
        allow_any_instance_of(Friendship).to receive(:errors).and_return(double(full_messages: ['Invalid friendship']))

        post :create, params: { friendship: { friend_username: friend.profile.username } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to eq(['Invalid friendship'])
      end
    end
  end

  describe 'PUT #accept' do
    context 'with valid parameters' do
      let!(:friendship) { create(:friendship, user: friend, friend: user, status: 'pending') }

      it 'accepts the friendship' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Friendship accepted successfully')
        expect(friendship.reload.status).to eq('accepted')
      end
    end

    context 'with invalid parameters' do
      it 'returns a not found error for non-existent friendship' do
        Friendship.where(friend: user, status: 'pending').destroy_all
        Friendship.where(user:, status: 'pending').destroy_all

        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Friendship request not found')
      end

      it 'returns unprocessable entity for invalid friendship update' do
        friendship = create(:friendship, user: friend, friend: user, status: 'pending')
        allow_any_instance_of(Friendship).to receive(:update).and_return(false)
        allow_any_instance_of(Friendship).to receive(:errors).and_return(double(full_messages: ['Invalid update']))

        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to eq(['Invalid update'])
      end
    end
  end
end
