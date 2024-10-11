# frozen_string_literal: true

# This controller manages friendship-related actions.
class FriendshipsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_friendship, only: [:destroy]

  def create
    friend = find_friend
    if friend
      create_friendship(friend)
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def accept
    friendship = find_friendship
    if friendship
      if friendship.update(status: 'accepted')
        render json: { message: 'Friendship accepted successfully' }, status: :ok
      else
        render json: { errors: friendship.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Friendship request not found' }, status: :not_found
    end
  end

  def decline
    friendship = find_friendship
    if friendship && friendship.friend == current_user
      if friendship.update(status: 'declined')
        render json: { message: 'Friend request declined' }, status: :ok
      else
        render json: { errors: friendship.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Friendship request not found' }, status: :not_found
    end
  end

  def destroy
    if @friendship&.destroy
      render json: { message: 'Friendship removed successfully' }, status: :ok

    else
      render json: { error: 'Friendship not found' }, status: :not_found
    end
  end

  private

  def friendship_params
    params.require(:friendship).permit(:friend_username, :friend_id)
  end

  def find_friend
    User.joins(:profile).find_by(profiles: { username: friendship_params[:friend_username] })
  end

  def create_friendship(friend)
    friendship = current_user.friendships.build(friend:)
    if friendship.save
      render json: { message: 'Friendship request sent successfully' }, status: :created
    else
      render json: { errors: friendship.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def find_friendship
    Friendship.find_by(user_id: params[:friendship][:friend_id], friend_id: current_user.id, status: 'pending') ||
      Friendship.find_by(user_id: current_user.id, friend_id: params[:friendship][:friend_id], status: 'pending')
  end

  def set_friendship
    @friendship = current_user.friendships.find_by(friend_id: params[:id]) ||
                  current_user.inverse_friendships.find_by(user_id: params[:id])

    render json: { error: 'Friendship not found' }, status: :not_found unless @friendship
  end
end
