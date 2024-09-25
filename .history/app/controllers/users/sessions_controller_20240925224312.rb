# frozen_string_literal: true

module Users
  # SessionsController
  # Handles user authentication process
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: {
        user: resource,
        token: JwtService.encode({ user_id: resource.id })
      }, status: :ok
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
