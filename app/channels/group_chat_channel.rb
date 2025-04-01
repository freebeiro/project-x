# frozen_string_literal: true

# Handles WebSocket communication for real-time chat within a group during a specific event.
class GroupChatChannel < ApplicationCable::Channel
  # Called when a client subscribes to the channel.
  # Authorizes the user and starts streaming messages for the specific group/event chat room.
  def subscribed
    # Perform checks; return immediately if any check fails (reject is called within checks)
    return unless current_user && load_group_and_event && check_authorization

    # If checks pass, proceed with streaming
    stream_from stream_name
    logger.info "#{current_user.email} subscribed to #{stream_name}"
  end

  # Called when a client sends data to the channel (e.g., a new message).
  # Creates the message record and broadcasts it to the stream.
  def receive(data)
    # Ensure group/event loaded and user still authorized
    return unless @group && @event && user_is_authorized?

    message = create_message(data['content'])
    return unless message # Return if message creation failed (e.g., blank content)

    if message.persisted?
      broadcast_message(message)
    else
      log_message_error(message)
      # Optionally transmit error back to sender
    end
  end

  # Called when the client unsubscribes or disconnects.
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    # Action Cable automatically stops streaming
    logger.info "#{current_user&.email || 'Unknown user'} unsubscribed from #{stream_name}" if @group && @event
  end

  private

  # Loads @group and @event based on params, returns false and rejects if not found/authorized.
  def load_group_and_event
    @group = Group.find_by(id: params[:group_id])
    @event = Event.find_by(id: params[:event_id])

    unless @group && @event
      # Use a simpler log message here as group/event might be nil
      log_msg = "User #{current_user&.id} failed subscription attempt - " \
                "Group(#{params[:group_id]}) or Event(#{params[:event_id]}) Not Found"
      logger.warn log_msg
      reject
      return false
    end
    true
  end

  # Checks if the current_user is authorized to participate in this chat.
  # Returns false and rejects if unauthorized.
  def check_authorization
    return true if user_is_authorized?

    logger.warn "#{log_prefix}failed subscription attempt - Unauthorized"
    reject
    false
  end

  # Creates and saves a new message. Returns the message object or nil.
  def create_message(content)
    return nil if content.blank?

    Message.create(
      content:,
      user: current_user,
      group: @group,
      event: @event
    )
  end

  # Broadcasts the formatted message to the stream.
  def broadcast_message(message)
    ActionCable.server.broadcast(stream_name, format_message(message))
    logger.info log_prefix + "broadcasted message #{message.id}"
  end

  # Logs message saving errors.
  def log_message_error(message)
    logger.error log_prefix + "failed to save message: #{message.errors.full_messages}"
  end

  # Prefix for log messages including user email.
  def log_prefix
    "#{current_user&.email || 'Unknown user'} in #{stream_name}: "
  end

  # Generates the unique stream name for this group/event chat.
  def stream_name
    "group_chat_#{@group.id}_event_#{@event.id}"
  end

  # Checks if the current_user is authorized to participate in this chat.
  # Placeholder: Implement actual authorization logic (e.g., check group membership, event participation status)
  def user_is_authorized?
    # Example: Check if user is a member of the group AND participating in the event
    is_group_member = @group.group_memberships.exists?(user_id: current_user.id)
    is_event_participant = @event.event_participations.exists?(user_id: current_user.id,
                                                               status: EventParticipation::STATUS_ATTENDING)

    # Require both for now, adjust logic as needed
    is_group_member && is_event_participant
  end

  # Formats the message for broadcasting.
  # Includes sender's username for display on the client-side.
  def format_message(message)
    {
      id: message.id,
      content: message.content,
      user_id: message.user_id,
      username: message.user.profile&.username || message.user.email, # Display username or email
      group_id: message.group_id,
      event_id: message.event_id,
      created_at: message.created_at.iso8601 # Use ISO8601 for JS compatibility
    }
  end
end
