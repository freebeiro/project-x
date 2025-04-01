# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:event, organizer_id: user.id) }
  let(:invalid_attributes) { attributes_for(:event, name: nil, organizer_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{JwtService.encode(user_id: user.id)}"
  end

  describe 'GET #index' do
    it 'returns a success response' do
      create(:event, organizer: user)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      event = create(:event, organizer: user)
      get :show, params: { id: event.to_param }
      expect(response).to be_successful
    end

    context 'with invalid event id' do
      it 'returns not found status' do
        get :show, params: { id: 'invalid' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Event' do
        expect do
          post :create, params: { event: valid_attributes }
        end.to change(Event, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: { event: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns JSON content type' do
        post :create, params: { event: valid_attributes }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity status for invalid params' do
        post :create, params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns JSON content type for invalid params' do
        post :create, params: { event: invalid_attributes }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PUT #update' do
    let(:event) { create(:event, organizer: user) }

    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Event Name' } }

      it 'updates the requested event' do
        put :update, params: { id: event.to_param, event: new_attributes }
        event.reload
        expect(event.name).to eq('Updated Event Name')
      end

      it 'returns successful status for show' do
        event = Event.create! valid_attributes
        get :show, params: { id: event.to_param }
        expect(response).to be_successful
      end

      it 'returns JSON content type for show' do
        event = Event.create! valid_attributes
        get :show, params: { id: event.to_param }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity status for invalid update' do
        event = Event.create! valid_attributes
        put :update, params: { id: event.to_param, event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns JSON content type for invalid update' do
        event = Event.create! valid_attributes
        put :update, params: { id: event.to_param, event: invalid_attributes }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when unauthorized' do
      it 'returns forbidden status when updating another user\'s event' do
        other_user = create(:user)
        event_unauthorized = create(:event, organizer: other_user) # Renamed variable
        put :update, params: { id: event_unauthorized.to_param, event: { name: 'New Name' } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid event id' do
      it 'returns not found status' do
        put :update, params: { id: 'invalid', event: { name: 'New Name' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested event' do
      event = create(:event, organizer: user)
      expect do
        delete :destroy, params: { id: event.to_param }
      end.to change(Event, :count).by(-1)
    end

    it 'returns no content status' do
      event = create(:event, organizer: user)
      delete :destroy, params: { id: event.to_param }
      expect(response).to have_http_status(:no_content)
    end
  end

  # Removed the duplicate describe blocks for GET #show and PUT #update
end
