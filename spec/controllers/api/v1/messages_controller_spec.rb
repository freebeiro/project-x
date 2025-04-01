# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:event) { create(:event, group_id: group.id) }

  before do
    authenticate_user(user)
  end

  describe 'GET #index' do
    let(:old_message) { create(:message, user:, group:, event:, created_at: 1.hour.ago) }
    let(:new_message) { create(:message, user:, group:, event:, created_at: 30.minutes.ago) }

    context 'when authorized' do
      before do
        create(:group_membership, group:, user:)
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
        old_message
        new_message
        get :index, params: { group_id: group.id, event_id: event.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct number of messages' do
        expect(response.parsed_body.size).to eq(2)
      end

      it 'returns only messages for the correct group and event' do
        expect(response.parsed_body.pluck('id')).to contain_exactly(old_message.id, new_message.id)
      end

      it 'returns messages ordered by creation time (oldest first)' do
        expect(response.parsed_body.first['id']).to eq(old_message.id)
      end

      it 'returns messages ordered by creation time (newest last)' do
        expect(response.parsed_body.second['id']).to eq(new_message.id)
      end

      it 'includes user username' do
        user.create_profile(attributes_for(:profile).except(:user_id)) unless user.profile
        get :index, params: { group_id: group.id, event_id: event.id }
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
      let(:other_group) { create(:group) }
      let(:unrelated_event) { create(:event, group: other_group, organizer: create(:user)) }

      before do
        create(:group_membership, group:, user:)
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
        get :index, params: { group_id: 999, event_id: unrelated_event.id }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid event_id' do
      before do
        create(:group_membership, group:, user:)
        get :index, params: { group_id: group.id, event_id: 999 }
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_message_params) { { message: { content: 'New message!' } } }
    let(:invalid_message_params) { { message: { content: '' } } }

    context 'when authorized' do
      before do
        create(:group_membership, group:, user:)
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
      end

      # Flattened structure to reduce nesting
      context 'with valid params' do
        let(:request_params) { { group_id: group.id, event_id: event.id }.merge(valid_message_params) }

        it 'creates a new Message' do
          expect { post :create, params: request_params }.to change(Message, :count).by(1)
        end

        it 'returns http created' do
          post :create, params: request_params
          expect(response).to have_http_status(:created)
        end

        # Test assignments after creation
        it 'assigns message to correct user' do
          post :create, params: request_params
          expect(Message.last.user).to eq(user)
        end

        it 'assigns message to correct group' do
          post :create, params: request_params
          expect(Message.last.group).to eq(group)
        end

        it 'assigns message to correct event' do
          post :create, params: request_params
          expect(Message.last.event).to eq(event)
        end

        it 'broadcasts the message via Action Cable' do
          ActiveJob::Base.queue_adapter = :test
          expect do
            post :create, params: request_params
          end.to have_broadcasted_to("group_chat_#{group.id}_event_#{event.id}")
            .with(hash_including(content: 'New message!'))
        end
      end

      context 'with invalid params' do
        let(:request_params) { { group_id: group.id, event_id: event.id }.merge(invalid_message_params) }

        it 'does not create a new Message' do
          expect { post :create, params: request_params }.not_to change(Message, :count)
        end

        it 'returns http unprocessable entity' do
          post :create, params: request_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not broadcast via Action Cable' do
          ActiveJob::Base.queue_adapter = :test
          expect do
            post :create, params: request_params
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
