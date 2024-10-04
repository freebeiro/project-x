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
    # Set @current_user explicitly
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
end
