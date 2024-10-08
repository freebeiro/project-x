# frozen_string_literal: true

# Controller for managing friendships between users
class FriendshipsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_friendship, only: [:update]

  def create
    friend = User.find_by(id: params[:friend_id])
    if friend.nil?
      render json: { error: 'Friend not found' }, status: :not_found
      return
    end

    @friendship = @current_user.friendships.build(friend:)

    save_friendship
  end

  def update
    if @friendship.friend == @current_user && @friendship.update(friendship_params)
      render json: { message: "Friend request #{@friendship.status}", data: @friendship }, status: :ok
    else
      render json: { errors: @friendship.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def save_friendship
    if @friendship.save
      render json: { message: 'Friend request sent successfully', data: @friendship }, status: :created
    else
      render json: { errors: @friendship.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def set_friendship
    @friendship = Friendship.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Friendship not found' }, status: :not_found
  end

  def friendship_params
    params.require(:friendship).permit(:status)
  end
end
