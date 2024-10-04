# frozen_string_literal: true

# Controller for managing group memberships
class GroupMembershipsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_group

  def create
    @membership = @group.group_memberships.build(user: @current_user)
    if @membership.save
      render_success
    else
      render_error
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Group not found' }, status: :not_found
  end

  def render_success
    render json: { message: 'Successfully joined the group' }, status: :created
  end

  def render_error
    render json: { errors: @membership.errors.full_messages }, status: :unprocessable_entity
  end
end
