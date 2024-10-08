# frozen_string_literal: true

class FriendshipsController < ApplicationController
  before_action :authenticate_user_from_token!

  def create
    friend = User.joins(:profile).find_by(profiles: { username: friendship_params[:friend_username] })
    if friend
      friendship = current_user.friendships.build(friend:)
      if friendship.save
        render json: { message: 'Friendship request sent successfully' }, status: :created
      else
        render json: { errors: friendship.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def accept
    friendship = Friendship.find_by(friend: current_user, status: 'pending') ||
                 Friendship.find_by(user: current_user, friend_id: friendship_params[:friend_id], status: 'pending')
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

  private

  def friendship_params
    params.require(:friendship).permit(:friend_username, :friend_id)
  end
end
