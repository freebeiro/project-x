# frozen_string_literal: true

module Api
  module V1
    # Handles API requests for chat messages within a group/event context.
    class MessagesController < ApplicationController
      # Ensure user is authenticated via token for all actions
      before_action :authenticate_user_from_token!
      # Load the relevant group and event based on URL parameters
      before_action :set_group_and_event
      # Ensure the current user is authorized to access this chat
      before_action :authorize_chat_access

      # GET /api/v1/groups/:group_id/events/:event_id/messages
      def index
        # Retrieve messages scoped to the specific group and event, ordered chronologically
        @messages = Message.where(group: @group, event: @event).order(created_at: :asc)
        # Render messages, including user ID and username via profile
        render json: @messages.as_json(include: { user: { only: [:id], include: { profile: { only: [:username] } } } })
      end

      # POST /api/v1/groups/:group_id/events/:event_id/messages
      def create
        @message = build_message
        if @message.save
          broadcast_message(@message)
          render json: @message, status: :created
        else
          render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Builds a new message instance with current user, group, and event context.
      def build_message
        Message.new(message_params.merge(
                      user: current_user,
                      group: @group,
                      event: @event
                    ))
      end

      # Finds the Group and Event based on URL parameters. Renders 404 if not found.
      def set_group_and_event
        @group = Group.find_by(id: params[:group_id])
        # Find event by id and ensure it belongs to the found group using group_id
        @event = @group&.events&.find_by(id: params[:event_id]) # Corrected lookup

        return if @group && @event

        render json: { error: 'Group or Event not found' }, status: :not_found
      end

      # Ensures the current user is part of the group and attending the event. Renders 403 if not.
      def authorize_chat_access
        # Ensure @group and @event are loaded before checking authorization
        return unless @group && @event

        is_group_member = @group.group_memberships.exists?(user_id: current_user.id)
        is_event_participant = @event.event_participations.exists?(user_id: current_user.id,
                                                                   status: EventParticipation::STATUS_ATTENDING)

        return if is_group_member && is_event_participant

        render json: { error: 'Not authorized to access this chat' }, status: :forbidden
      end

      # Strong parameters for message creation. Only allows 'content'.
      def message_params
        params.require(:message).permit(:content)
      end

      # Helper to broadcast the message via Action Cable.
      def broadcast_message(message)
        ActionCable.server.broadcast(stream_name_for_broadcast, formatted_message_for_broadcast(message))
      end

      # Generates the stream name for broadcasting.
      def stream_name_for_broadcast
        "group_chat_#{@group.id}_event_#{@event.id}"
      end

      # Formats the message data for broadcasting.
      def formatted_message_for_broadcast(message)
        username = message.user.profile&.username || message.user.email
        {
          id: message.id,
          content: message.content,
          user_id: message.user_id,
          username:,
          group_id: message.group_id,
          event_id: message.event_id,
          created_at: message.created_at.iso8601
        }
      end
    end
  end
end
