# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupChatChannel, type: :channel do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  # Associate event with the group
  let(:event) { create(:event, organizer: create(:user), group:) }

  # Stub the connection and identify the current user
  before do
    stub_connection current_user: user
  end

  describe '#subscribed' do
    context 'when user is authorized (member and participant)' do
      # Ensure user is member and participant before subscribing
      before do
        create(:group_membership, group:, user:)
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
      end

      it 'successfully subscribes' do
        subscribe(group_id: group.id, event_id: event.id)
        expect(subscription).to be_confirmed
      end

      it 'streams from the correct channel' do
        subscribe(group_id: group.id, event_id: event.id)
        expect(subscription).to have_stream_from("group_chat_#{group.id}_event_#{event.id}")
      end
    end

    context 'when user is not a group member' do
      before do
        # User is participant but not group member
        create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
      end

      it 'rejects the subscription' do
        subscribe(group_id: group.id, event_id: event.id)
        expect(subscription).to be_rejected
      end
    end

    context 'when user is not an event participant' do
      before do
        # User is group member but not participant
        create(:group_membership, group:, user:)
      end

      it 'rejects the subscription' do
        subscribe(group_id: group.id, event_id: event.id)
        expect(subscription).to be_rejected
      end
    end

    context 'with invalid group_id' do
      it 'rejects the subscription' do
        subscribe(group_id: 999, event_id: event.id)
        expect(subscription).to be_rejected
      end
    end

    context 'with invalid event_id' do
      it 'rejects the subscription' do
        subscribe(group_id: group.id, event_id: 999)
        expect(subscription).to be_rejected
      end
    end
  end

  describe '#receive' do
    let(:message_content) { 'Hello from test!' }
    let(:data) { { 'content' => message_content, 'group_id' => group.id, 'event_id' => event.id } }

    before do
      # Ensure user is authorized and subscribed before performing receive
      create(:group_membership, group:, user:)
      create(:event_participation, event:, user:, status: EventParticipation::STATUS_ATTENDING)
      subscribe(group_id: group.id, event_id: event.id)
    end

    # Added test specifically for confirmation
    it 'confirms the subscription' do
      expect(subscription).to be_confirmed
    end

    # Split 'creates a new message' test
    it 'increments the Message count' do
      expect { perform :receive, data }.to change(Message, :count).by(1)
    end

    context 'when message is created' do
      # Perform the action once for subsequent checks
      before { perform :receive, data }

      let(:created_message) { Message.last }

      it 'assigns the correct content' do
        expect(created_message.content).to eq(message_content)
      end

      it 'assigns the correct user' do
        expect(created_message.user).to eq(user)
      end

      it 'assigns the correct group' do
        expect(created_message.group).to eq(group)
      end

      it 'assigns the correct event' do
        expect(created_message.event).to eq(event)
      end
    end

    it 'broadcasts the message to the stream' do
      # Check that broadcast_to is called with the correct stream and message format
      # Note: format_message includes username, so ensure profile exists or email is used
      expect do
        perform :receive, data
      end.to have_broadcasted_to("group_chat_#{group.id}_event_#{event.id}")
        .with(hash_including(content: message_content, user_id: user.id))
    end

    context 'with blank content' do
      it 'does not create a message' do
        expect do
          perform :receive, { 'content' => '', 'group_id' => group.id, 'event_id' => event.id }
        end.not_to change(Message, :count)
      end

      it 'does not broadcast' do
        expect do
          perform :receive, { 'content' => '', 'group_id' => group.id, 'event_id' => event.id }
        end.not_to have_broadcasted_to("group_chat_#{group.id}_event_#{event.id}")
      end
    end
  end
end
