# frozen_string_literal: true

# GroupsController handles group-related actions
class GroupsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_group, only: [:show]

  def show
    render json: @group
  end

  def create
    @group = @current_user.administered_groups.build(group_params)
    if @group.save
      render json: { message: 'Group created successfully', data: @group }, status: :created
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

  def group_params
    params.require(:group).permit(:name, :description, :privacy, :member_limit)
  end
end
