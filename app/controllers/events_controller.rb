# frozen_string_literal: true

# Handles event management operations
class EventsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_event, only: %i[show update destroy]
  before_action :authorize_organizer!, only: %i[update destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # GET /events
  def index
    @events = Event.all
    render json: @events
  end

  # GET /events/1
  def show
    render json: @event
  end

  # POST /groups/:group_id/events
  def create
    # Find the group first using the group_id from the nested route
    find_group_or_render_not_found
    return unless @group # Return if group wasn't found

    # Build the event through the group association, also setting the organizer
    @event = @group.events.new(event_params.merge(organizer: current_user))

    if @event.save
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    head :no_content
  end

  private

  # Helper to find group or render 404
  def find_group_or_render_not_found
    @group = Group.find_by(id: params[:group_id])
    render json: { error: 'Group not found' }, status: :not_found unless @group
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_organizer!
    return if @event.organizer == current_user

    render json: { error: 'Not authorized' }, status: :forbidden
  end

  def record_not_found
    render json: { error: 'Event not found' }, status: :not_found
  end

  def event_params
    params.require(:event).permit(
      :name,
      :description,
      :location,
      :start_time,
      :end_time,
      :capacity
    )
  end
end
