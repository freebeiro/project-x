# frozen_string_literal: true

# Handles event participation operations including:
# - Joining/leaving events
# - Listing event participants
class EventParticipationsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_event
  before_action :set_participation, only: [:destroy]
  before_action :check_event_capacity, only: [:create] # Added capacity check

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # GET /events/:event_id/participations
  def index
    @participations = @event.event_participations
    render json: @participations
  end

  # POST /events/:event_id/participations
  def create
    @participation = @event.event_participations.new(
      user: current_user, # Removed capacity check from here
      status: participation_status
    )

    if @participation.save
      render json: @participation, status: :created
    else
      render json: @participation.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/:event_id/participations/1
  def destroy
    @participation.destroy
    head :no_content
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  # Added private method for capacity check
  def check_event_capacity
    return unless @event.at_capacity?

    render json: { error: 'Event is at capacity' }, status: :unprocessable_entity
  end

  def record_not_found
    # If params[:id] is present, it's likely a participation lookup failed.
    # Otherwise, it's likely the event lookup failed.
    error_message = params[:id] ? 'Participation not found' : 'Event not found'
    render json: { error: error_message }, status: :not_found
  end

  def set_participation
    # Find participation scoped to the event AND current user. Use find to raise error if not found.
    @participation = @event.event_participations.find_by!(id: params[:id], user: current_user)
  end

  def participation_status
    EventParticipation::STATUS_ATTENDING
  end
end
