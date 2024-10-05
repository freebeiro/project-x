# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before do
    allow(controller).to receive(:authenticate_user_from_token!)
    controller.instance_variable_set(:@current_user, user)
  end

  describe 'POST #create' do
    subject(:create_friendship) { post :create, params: { friend_id: friend.id } }

    context 'when the friendship is valid' do
      it 'creates a new friendship' do
        expect { create_friendship }.to change(Friendship, :count).by(1)
      end

      it 'returns a created status' do
        create_friendship
        expect(response).to have_http_status(:created)
      end

      it 'returns a success message' do
        create_friendship
        expect(response.parsed_body['message']).to eq('Friend request sent successfully')
      end
    end

    context 'when the friendship is invalid' do
      before { create(:friendship, user:, friend:) }

      it 'does not create a new friendship' do
        expect { create_friendship }.not_to change(Friendship, :count)
      end

      it 'returns an unprocessable entity status' do
        create_friendship
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        create_friendship
        expect(response.parsed_body).to have_key('errors')
      end
    end

    context 'when the friend does not exist' do
      subject(:create_invalid_friendship) { post :create, params: { friend_id: 'nonexistent' } }

      it 'returns a not found status' do
        create_invalid_friendship
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #update' do
    subject(:update_friendship) do
      put :update, params: { id: friendship.id, friendship: { status: } }
    end

    let(:friendship) { create(:friendship, user: friend, friend: user, status: 'pending') }

    context 'when the update is valid' do
      let(:status) { 'accepted' }

      it 'updates the friendship status' do
        update_friendship
        expect(friendship.reload.status).to eq('accepted')
      end

      it 'returns an ok status' do
        update_friendship
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        update_friendship
        expect(response.parsed_body['message']).to eq('Friend request accepted')
      end
    end

    context 'when the update is invalid' do
      let(:status) { 'invalid' }

      it 'does not update the friendship status' do
        update_friendship
        expect(friendship.reload.status).to eq('pending')
      end

      it 'returns an unprocessable entity status' do
        update_friendship
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        update_friendship
        expect(response.parsed_body).to have_key('errors')
      end
    end

    context 'when the friendship does not exist' do
      subject(:update_nonexistent_friendship) do
        put :update, params: { id: 'nonexistent', friendship: { status: 'accepted' } }
      end

      it 'returns a not found status' do
        update_nonexistent_friendship
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is not the friend in the friendship' do
      subject(:update_other_friendship) do
        put :update, params: { id: other_friendship.id, friendship: { status: 'accepted' } }
      end

      let(:other_friendship) { create(:friendship, user: create(:user), friend: create(:user), status: 'pending') }

      it 'does not update the friendship' do
        update_other_friendship
        expect(other_friendship.reload.status).to eq('pending')
      end

      it 'returns an unprocessable entity status' do
        update_other_friendship
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
