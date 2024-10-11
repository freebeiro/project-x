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
      let(:valid_params) { { friendship: { friend_username: friend.profile.username } } }

      it 'creates a new friendship' do
        expect { post :create, params: valid_params }.to change(Friendship, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns a success message' do
        post :create, params: valid_params
        expect(response.parsed_body['message']).to eq('Friendship request sent successfully')
      end
    end

    context 'with non-existent user' do
      let(:invalid_params) { { friendship: { friend_username: 'nonexistent' } } }

      it 'returns a not found status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found error message' do
        post :create, params: invalid_params
        expect(response.parsed_body['error']).to eq('User not found')
      end
    end

    context 'with invalid friendship' do
      let(:valid_params) { { friendship: { friend_username: friend.profile.username } } }

      before do
        friendship = build(:friendship)
        allow(friendship).to receive_messages(save: false,
                                              errors: instance_double(
                                                ActiveModel::Errors, full_messages: ['Invalid friendship']
                                              ))
        allow(Friendship).to receive(:new).and_return(friendship)
      end

      it 'returns unprocessable entity status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post :create, params: valid_params
        expect(response.parsed_body['errors']).to eq(['Invalid friendship'])
      end
    end
  end

  describe 'PUT #accept' do
    let!(:friendship) { create(:friendship, user: friend, friend: user, status: 'pending') }
    let(:valid_params) { { friendship: { friend_id: friend.id } } }

    context 'with valid parameters' do
      it 'returns status ok' do
        put :accept, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        put :accept, params: valid_params
        expect(response.parsed_body['message']).to eq('Friendship accepted successfully')
      end

      it 'updates friendship status to accepted' do
        put :accept, params: valid_params
        expect(friendship.reload.status).to eq('accepted')
      end
    end

    context 'with non-existent friendship' do
      before do
        Friendship.where(friend: user, status: 'pending').destroy_all
        Friendship.where(user:, status: 'pending').destroy_all
      end

      it 'returns a not found status' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found error message' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response.parsed_body['error']).to eq('Friendship request not found')
      end
    end

    context 'with invalid friendship update' do
      before do
        allow(Friendship).to receive(:find_by).and_return(friendship)
        allow(friendship).to receive_messages(update: false,
                                              errors: instance_double(
                                                ActiveModel::Errors, full_messages: ['Invalid update']
                                              ))
      end

      it 'returns unprocessable entity status' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        put :accept, params: { friendship: { friend_id: friend.id } }
        expect(response.parsed_body['errors']).to eq(['Invalid update'])
      end
    end
  end

  describe 'PUT #decline' do
    let!(:friendship) { create(:friendship, user: friend, friend: user, status: 'pending') }
    let(:valid_params) { { friendship: { friend_id: friend.id } } }

    context 'with valid parameters' do
      it 'returns status ok' do
        put :decline, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        put :decline, params: valid_params
        expect(response.parsed_body['message']).to eq('Friend request declined')
      end

      it 'updates friendship status to declined' do
        put :decline, params: valid_params
        expect(friendship.reload.status).to eq('declined')
      end
    end

    context 'with non-existent friendship' do
      before do
        Friendship.where(friend: user, status: 'pending').destroy_all
      end

      it 'returns a not found status' do
        put :decline, params: { friendship: { friend_id: friend.id } }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found error message' do
        put :decline, params: { friendship: { friend_id: friend.id } }
        expect(response.parsed_body['error']).to eq('Friendship request not found')
      end
    end

    context 'with invalid friendship update' do
      let(:friendship) { create(:friendship, user: friend, friend: user, status: 'pending') }

      before do
        allow(Friendship).to receive(:find_by).and_return(friendship)
        allow(friendship).to receive_messages(update: false,
                                              errors: instance_double(
                                                ActiveModel::Errors, full_messages: ['Invalid update']
                                              ))
      end

      it 'returns unprocessable entity status' do
        put :decline, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        put :decline, params: valid_params
        expect(response.parsed_body['errors']).to eq(['Invalid update'])
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:friendship) { create(:friendship, user:, friend:, status: 'accepted') }

    before do
      friendship
    end

    context 'when friendship exists' do
      it 'destroys the friendship' do
        expect { delete :destroy, params: { id: friend.id } }.to change(Friendship, :count).by(-1)
      end

      it 'returns a success status' do
        delete :destroy, params: { id: friend.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        delete :destroy, params: { id: friend.id }
        expect(response.parsed_body['message']).to eq('Friendship removed successfully')
      end
    end

    context 'when friendship does not exist' do
      before do
        allow(controller).to receive(:set_friendship).and_return(nil)
      end

      it 'returns a not found status' do
        delete :destroy, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        delete :destroy, params: { id: 999 }
        expect(response.parsed_body['error']).to eq('Friendship not found')
      end
    end

    context 'when friendship fails to destroy' do
      let(:friendship) { create(:friendship, user:, friend:, status: 'accepted') }

      before do
        allow(controller).to receive(:set_friendship).and_return(friendship)
        allow(friendship).to receive_messages(destroy: false,
                                              errors: instance_double(
                                                ActiveModel::Errors, full_messages: ['Failed to destroy friendship']
                                              ))
      end

      it 'returns unprocessable entity status' do
        delete :destroy, params: { id: friend.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        delete :destroy, params: { id: friend.id }
        expect(response.parsed_body['errors']).to eq(['Failed to destroy friendship'])
      end
    end

    context 'when user is the friend in the friendship' do
      before do
        authenticate_user(friend)
      end

      it 'destroys the friendship' do
        expect { delete :destroy, params: { id: user.id } }.to change(Friendship, :count).by(-1)
      end

      it 'returns a success status' do
        delete :destroy, params: { id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        delete :destroy, params: { id: user.id }
        expect(response.parsed_body['message']).to eq('Friendship removed successfully')
      end
    end
  end
end
