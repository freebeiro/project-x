# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      name: 'Test Group',
      description: 'A test group',
      privacy: 'public',
      member_limit: 10
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      privacy: 'invalid',
      member_limit: 0
    }
  end

  before do
    allow(controller).to receive_messages(authenticate_user_from_token!: true, current_user: user)
    controller.instance_variable_set(:@current_user, user)
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Group' do
        expect do
          post :create, params: { group: valid_attributes }
        end.to change(Group, :count).by(1)
      end

      it 'renders a JSON response with created status' do
        post :create, params: { group: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'renders a JSON response with the correct content type' do
        post :create, params: { group: valid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Group' do
        expect do
          post :create, params: { group: invalid_attributes }
        end.not_to change(Group, :count)
      end

      it 'renders a JSON response with unprocessable_entity status' do
        post :create, params: { group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders a JSON response with the correct content type' do
        post :create, params: { group: invalid_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'GET #show' do
    let(:group) { create(:group, admin: user) }

    it 'returns a success response' do
      get :show, params: { id: group.to_param }
      expect(response).to be_successful
    end

    it 'returns the correct group' do
      get :show, params: { id: group.to_param }
      json_response = response.parsed_body
      expect(json_response['id']).to eq(group.id)
    end

    context 'when the group does not exist' do
      it 'returns a not found response' do
        get :show, params: { id: 'invalid_id' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #update' do
    let(:group) { create(:group, admin: user) }
    let(:new_attributes) { { name: 'Updated Group Name' } }

    context 'when user is the group admin' do
      it 'updates the requested group' do
        put :update, params: { id: group.to_param, group: new_attributes }
        group.reload
        expect(group.name).to eq('Updated Group Name')
      end

      it 'renders a JSON response with ok status' do
        put :update, params: { id: group.to_param, group: new_attributes }
        expect(response).to have_http_status(:ok)
      end

      it 'renders a JSON response with the correct content type' do
        put :update, params: { id: group.to_param, group: new_attributes }
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the group' do
        put :update, params: { id: group.to_param, group: invalid_attributes }
        group.reload
        expect(group.name).not_to eq('')
      end

      it 'returns error messages' do
        put :update, params: { id: group.to_param, group: invalid_attributes }
        json_response = response.parsed_body
        expect(json_response).to have_key('errors')
      end

      it 'returns non-empty error messages' do
        put :update, params: { id: group.to_param, group: invalid_attributes }
        json_response = response.parsed_body
        expect(json_response['errors']).not_to be_empty
      end
    end

    context 'when user is not the group admin' do
      let(:other_user) { create(:user) }
      let(:non_admin_update) do
        allow(controller).to receive(:current_user).and_return(other_user)
        controller.instance_variable_set(:@current_user, other_user)
        put :update, params: { id: group.to_param, group: new_attributes }
      end

      it 'does not update the group' do
        original_name = group.name
        non_admin_update
        group.reload
        expect(group.name).to eq(original_name)
      end

      it 'renders a forbidden response' do
        non_admin_update
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
