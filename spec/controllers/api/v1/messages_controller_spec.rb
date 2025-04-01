# frozen_string_literal: true

require 'rails_helper'

# NOTE: Using type: :request specs is often preferred for API testing
# as it tests the full stack including routing.
# These controller specs focus on the controller logic in isolation.
RSpec.describe Api::V1::MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  # Pass group_id instead of group object to factory
  let(:event) { create(:event, group_id: group.id) }

  # Helper to simulate authentication
  before do
    # Need helper from rails_helper or similar to set auth header
    # Assuming authenticate_user(user) sets request.headers['Authorization']
    authenticate_user(user)
  end

  describe 'GET #index' do
    let!(:message1) { create(:message, user:, group:, event:, created_at: 1.hour.ago) }
    let!(:message2) { create(:message, user:, group:, event:, created_at: 30.minutes.ago) }
    # Removed unused :other_message that caused validation errors
    # let!(:other_message) { create(:message) }

    context 'when authorized' do
      before do
        # Ensure user is authorized
        create(:group_membership, group:, user:)
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
        get :index, params: { group_id: group.id, event_id: event.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns messages for the correct group and event' do
        expect(response.parsed_body.size).to eq(2)
        expect(response.parsed_body.pluck('id')).to contain_exactly(message1.id, message2.id)
      end

      it 'returns messages ordered by creation time' do
        expect(response.parsed_body.first['id']).to eq(message1.id)
        expect(response.parsed_body.second['id']).to eq(message2.id)
      end

      it 'includes user username' do
        # Ensure user has a profile for username check
        user.create_profile(attributes_for(:profile).except(:user_id)) unless user.profile
        get :index, params: { group_id: group.id, event_id: event.id } # Re-run get after profile creation
        # Access username via nested profile in the JSON response
        expect(response.parsed_body.first['user']['profile']['username']).to eq(user.profile.username)
      end
    end

    context 'when not authorized (not group member)' do
      before do
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
        get :index, params: { group_id: group.id, event_id: event.id }
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not authorized (not event participant)' do
      before do
        create(:group_membership, group:, user:)
        get :index, params: { group_id: group.id, event_id: event.id }
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid group_id' do
      before do
        get :index, params: { group_id: 999, event_id: event.id }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid event_id' do
      before do
        get :index, params: { group_id: group.id, event_id: 999 }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_message_params) { { message: { content: 'New message!' } } }
    let(:invalid_message_params) { { message: { content: '' } } } # Blank content

    context 'when authorized' do
      before do
        # Ensure user is authorized
        create(:group_membership, group:, user:)
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
      end

      context 'with valid params' do
        it 'creates a new Message' do
          expect do
            post :create, params: { group_id: group.id, event_id: event.id }.merge(valid_message_params)
          end.to change(Message, :count).by(1)
        end

        it 'returns http created' do
          post :create, params: { group_id: group.id, event_id: event.id }.merge(valid_message_params)
          expect(response).to have_http_status(:created)
        end

        it 'assigns message to correct user, group, and event' do
          post :create, params: { group_id: group.id, event_id: event.id }.merge(valid_message_params)
          message = Message.last
          expect(message.user).to eq(user)
          expect(message.group).to eq(group)
          expect(message.event).to eq(event)
        end

        it 'broadcasts the message via Action Cable' do
          # Ensure ActiveJob uses test adapter for channels
          ActiveJob::Base.queue_adapter = :test
          expect do
            post :create, params: { group_id: group.id, event_id: event.id }.merge(valid_message_params)
          end.to have_broadcasted_to("group_chat_#{group.id}_event_#{event.id}")
            .with(hash_including(content: 'New message!'))
        end
      end

      context 'with invalid params' do
        it 'does not create a new Message' do
          expect do
            post :create, params: { group_id: group.id, event_id: event.id }.merge(invalid_message_params)
          end.not_to change(Message, :count)
        end

        it 'returns http unprocessable entity' do
          post :create, params: { group_id: group.id, event_id: event.id }.merge(invalid_message_params)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not broadcast via Action Cable' do
          ActiveJob::Base.queue_adapter = :test
          expect do
            post :create, params: { group_id: group.id, event_id: event.id }.merge(invalid_message_params)
          end.not_to have_broadcasted_to("group_chat_#{group.id}_event_#{event.id}")
        end
      end
    end

    context 'when not authorized' do
      it 'does not create a message' do
        expect do
          post :create, params: { group_id: group.id, event_id: event.id }.merge(valid_message_params)
        end.not_to change(Message, :count)
      end

      it 'returns http forbidden' do
        post :create, params: { group_id: group.id, event_id: event.id }.merge(valid_message_params)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
