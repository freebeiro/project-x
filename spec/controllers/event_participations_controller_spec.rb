# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventParticipationsController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group) } # Add group
  # Associate event with group
  let(:event) { create(:event, capacity: 2, group:) }
  # valid_attributes might not be needed if not used directly in params
  # let(:valid_attributes) { { event_id: event.id, user_id: user.id } }

  before do
    request.headers['Authorization'] = "Bearer #{JwtService.encode(user_id: user.id)}"
  end

  describe 'authentication' do
    context 'when not authenticated' do
      before do
        request.headers['Authorization'] = nil
      end

      it 'rejects access to index' do
        get :index, params: { group_id: group.id, event_id: event.id } # Add group_id
        expect(response).to have_http_status(:unauthorized)
      end

      it 'rejects access to create' do
        post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        expect(response).to have_http_status(:unauthorized)
      end

      it 'rejects access to destroy' do
        delete :destroy, params: { group_id: group.id, event_id: event.id, id: 1 } # Add group_id
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #index' do
    let(:participation) { create(:event_participation, event:, user:) } # Changed let! to let

    before do
      # Ensure participation is created before the request
      participation
      get :index, params: { group_id: group.id, event_id: event.id } # Add group_id
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the correct number of participations' do
      expect(json_response.size).to eq(1)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new participation' do
        expect do
          post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        end.to change(EventParticipation, :count).by(1)
      end

      it 'returns success response' do
        post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        expect(response).to have_http_status(:created)
      end
    end

    context 'when event is at capacity' do
      before do
        2.times { create(:event_participation, event:) }
      end

      it 'does not create a new participation' do
        expect do
          post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        end.not_to change(EventParticipation, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the correct error message' do
        post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        expect(json_response['error']).to eq('Event is at capacity')
      end
    end

    context 'when save fails' do
      # TODO: Refactor to avoid allow_any_instance_of if possible
      # rubocop:disable RSpec/AnyInstance
      it 'returns unprocessable entity response' do
        allow_any_instance_of(EventParticipation).to receive(:save).and_return(false)
        post :create, params: { group_id: group.id, event_id: event.id } # Add group_id
        expect(response).to have_http_status(:unprocessable_entity)
      end
      # rubocop:enable RSpec/AnyInstance
    end
  end

  describe 'DELETE #destroy' do
    let!(:participation) { create(:event_participation, event:, user:) }

    it 'destroys the participation record' do
      expect do
        delete :destroy, params: { group_id: group.id, event_id: event.id, id: participation.id } # Add group_id
      end.to change(EventParticipation, :count).by(-1)
    end

    it 'returns no content status' do
      delete :destroy, params: { group_id: group.id, event_id: event.id, id: participation.id } # Add group_id
      expect(response).to have_http_status(:no_content)
    end

    context 'when participation does not exist' do
      it 'returns not found' do
        delete :destroy, params: { group_id: group.id, event_id: event.id, id: 999 } # Add group_id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when participation does not belong to user' do
      let(:other_user) { create(:user) }
      let!(:other_participation) { create(:event_participation, event:, user: other_user) }

      it 'returns not found' do
        delete :destroy, params: { group_id: group.id, event_id: event.id, id: other_participation.id } # Add group_id
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  private

  def json_response
    response.parsed_body
  end
end
