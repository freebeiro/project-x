# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupMembershipsController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  before do
    allow(controller).to receive_messages(
      authenticate_user_from_token!: true,
      current_user: user
    )
    controller.instance_variable_set(:@current_user, user)
  end

  describe 'POST #create' do
    it 'creates a new group membership' do
      expect do
        post :create, params: { group_id: group.id }
      end.to change(GroupMembership, :count).by(1)
    end

    context 'when save is unsuccessful' do
      let(:invalid_membership) do
        instance_double(GroupMembership, save: false,
                                         errors: instance_double(ActiveModel::Errors, full_messages: ['Error message']))
      end
      let(:group_memberships) do
        instance_double(ActiveRecord::Associations::CollectionProxy, build: invalid_membership)
      end

      before do
        allow(Group).to receive(:find).and_return(group)
        allow(group).to receive(:group_memberships).and_return(group_memberships)
      end

      it 'renders error' do
        post :create, params: { group_id: group.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post :create, params: { group_id: group.id }
        expect(response.parsed_body).to have_key('errors')
      end
    end

    context 'when group does not exist' do
      it 'returns not found status' do
        post :create, params: { group_id: 'nonexistent_id' }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        post :create, params: { group_id: 'nonexistent_id' }
        expect(response.parsed_body['error']).to eq('Group not found')
      end
    end
  end
end
