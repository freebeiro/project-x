# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group, admin: user) } # Create a group for nesting
  # Update factories to include group_id
  let(:valid_attributes) { attributes_for(:event, organizer_id: user.id, group_id: group.id) }
  let(:invalid_attributes) { attributes_for(:event, name: nil, organizer_id: user.id, group_id: group.id) }

  before do
    request.headers['Authorization'] = "Bearer #{JwtService.encode(user_id: user.id)}"
  end

  describe 'GET #index' do
    it 'returns a success response' do
      create(:event, organizer: user, group:) # Associate event with group
      get :index, params: { group_id: group.id } # Add group_id
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    # Create event associated with the group
    let(:event) { create(:event, organizer: user, group:) }

    it 'returns a success response' do
      get :show, params: { group_id: group.id, id: event.to_param } # Add group_id
      expect(response).to be_successful
    end

    context 'with invalid event id' do
      it 'returns not found status' do
        get :show, params: { group_id: group.id, id: 'invalid' } # Add group_id
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    # POST requests need group_id in params
    context 'with valid params' do
      it 'creates a new Event' do
        expect do
          # Add group_id to params
          post :create, params: { group_id: group.id, event: valid_attributes }
        end.to change(Event, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: { group_id: group.id, event: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns JSON content type' do
        post :create, params: { group_id: group.id, event: valid_attributes }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity status for invalid params' do
        post :create, params: { group_id: group.id, event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns JSON content type for invalid params' do
        post :create, params: { group_id: group.id, event: invalid_attributes }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PUT #update' do
    # Create event associated with the group
    let(:event) { create(:event, organizer: user, group:) }

    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Event Name' } }

      it 'updates the requested event' do
        # Add group_id to params
        put :update, params: { group_id: group.id, id: event.to_param, event: new_attributes }
        event.reload
        expect(event.name).to eq('Updated Event Name')
      end

      # These two tests seem misplaced in PUT #update, they test GET #show
      # They also create a new event instead of using the let(:event)
      # Commenting out for now, can be moved/adjusted if needed.
      # it 'returns successful status for show' do
      #   event_show = create(:event, organizer: user, group: group) # Needs group
      #   get :show, params: { group_id: group.id, id: event_show.to_param }
      #   expect(response).to be_successful
      # end
      #
      # it 'returns JSON content type for show' do
      #   event_show = create(:event, organizer: user, group: group) # Needs group
      #   get :show, params: { group_id: group.id, id: event_show.to_param }
      #   expect(response.content_type).to match(a_string_including('application/json'))
      # end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity status for invalid update' do
        # Use the let(:event) defined above
        put :update, params: { group_id: group.id, id: event.to_param, event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns JSON content type for invalid update' do
        put :update, params: { group_id: group.id, id: event.to_param, event: invalid_attributes }
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'when unauthorized' do
      it 'returns forbidden status when updating another user\'s event' do
        other_user = create(:user)
        # Ensure unauthorized event belongs to the same group for routing
        event_unauthorized = create(:event, organizer: other_user, group:)
        put :update, params: { group_id: group.id, id: event_unauthorized.to_param, event: { name: 'New Name' } }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid event id' do
      it 'returns not found status' do
        put :update, params: { group_id: group.id, id: 'invalid', event: { name: 'New Name' } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    # Create event associated with the group
    let!(:event) { create(:event, organizer: user, group:) }

    it 'destroys the requested event' do
      expect do
        # Add group_id to params
        delete :destroy, params: { group_id: group.id, id: event.to_param }
      end.to change(Event, :count).by(-1)
    end

    it 'returns no content status' do
      delete :destroy, params: { group_id: group.id, id: event.to_param }
      expect(response).to have_http_status(:no_content)
    end

    # Add test for unauthorized delete
    context 'when unauthorized' do
      let(:other_user) { create(:user) }
      let!(:event_unauthorized) { create(:event, organizer: other_user, group:) }

      it 'does not destroy the event' do
        expect do
          delete :destroy, params: { group_id: group.id, id: event_unauthorized.to_param }
        end.not_to change(Event, :count)
      end

      it 'returns http forbidden' do
        delete :destroy, params: { group_id: group.id, id: event_unauthorized.to_param }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # Removed the duplicate describe blocks for GET #show and PUT #update
end
