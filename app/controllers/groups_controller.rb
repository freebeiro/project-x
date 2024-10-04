# frozen_string_literal: true

# GroupsController handles group-related actions
class GroupsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_group, only: %i[show update]
  before_action :ensure_admin, only: [:update]

  def show
    Rails.logger.debug { "Current user in show action: #{@current_user.inspect}" }
    render json: @group
  end

  def create
    Rails.logger.debug { "Current user in create action: #{@current_user.inspect}" }
    @group = @current_user.administered_groups.build(group_params)
    if @group.save
      render json: { message: 'Group created successfully', data: @group }, status: :created
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    Rails.logger.debug { "Current user in update action: #{@current_user.inspect}" }
    Rails.logger.debug { "Group admin: #{@group.admin.inspect}" }
    if @group.update(group_params)
      render json: { message: 'Group updated successfully', data: @group }
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Group not found' }, status: :not_found
  end

  def ensure_admin
    Rails.logger.debug do
      "Ensuring admin. Current user: #{@current_user.inspect}, Group admin: #{@group.admin.inspect}"
    end
    unless @group.admin == @current_user
      Rails.logger.debug 'User is not the group admin'
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
      return false
    end
    Rails.logger.debug 'User is the group admin'
    true
  end

  def group_params
    params.require(:group).permit(:name, :description, :privacy, :member_limit)
  end
end
