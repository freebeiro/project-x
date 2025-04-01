# frozen_string_literal: true

module Api
  module V1
    # Handles API requests for posts within a group/event context.
    class PostsController < ApplicationController
      before_action :authenticate_user_from_token!
      before_action :set_group_and_event
      before_action :authorize_post_access # Renamed for clarity

      # GET /api/v1/groups/:group_id/events/:event_id/posts
      def index
        @posts = Post.where(group: @group, event: @event).with_attached_images.order(created_at: :desc)
        # Include image URLs in the response
        render json: @posts.map { |post| post_json(post) }
      end

      # POST /api/v1/groups/:group_id/events/:event_id/posts
      def create
        @post = Post.new(post_params.merge(
                           user: current_user,
                           group: @group,
                           event: @event
                         ))

        if @post.save
          render json: post_json(@post), status: :created
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Finds the Group and Event based on URL parameters. Renders 404 if not found.
      def set_group_and_event
        @group = Group.find_by(id: params[:group_id])
        @event = @group&.events&.find_by(id: params[:event_id])

        return if @group && @event

        render json: { error: 'Group or Event not found' }, status: :not_found
      end

      # Ensures the current user is part of the group. Renders 403 if not.
      def authorize_post_access
        return unless @group && @event # Ensure resources are loaded

        is_group_member = @group.group_memberships.exists?(user_id: current_user.id)
        # Allow if user is a member of the group associated with the event
        return if is_group_member

        render json: { error: 'Not authorized to access posts for this group/event' }, status: :forbidden
      end

      # Strong parameters for post creation. Allows 'content' and 'images' array.
      # Use fetch to handle potentially empty :post params gracefully.
      def post_params
        params.fetch(:post, {}).permit(:content, images: [])
      end

      # Helper to generate JSON representation of a post, including image URLs.
      def post_json(post)
        post.as_json(include: { user: { only: [:id], include: { profile: { only: [:username] } } } })
            .merge(image_urls: image_urls(post))
      end

      # Helper to get URLs for attached images.
      def image_urls(post)
        # Ensure Rails routes helpers are available if generating URLs outside of request context
        # For simplicity here, assuming url_for works in this context.
        # May need Rails.application.routes.url_helpers.url_for(image) in other contexts.
        post.images.map { |image| url_for(image) } if post.images.attached?
      end
    end
  end
end
