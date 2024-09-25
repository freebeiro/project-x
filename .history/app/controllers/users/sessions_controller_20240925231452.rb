# frozen_string_literal: true

module Users
  # SessionsController
  # Handles user authentication process
  class SessionsController < Devise::SessionsController
    respond_to :json
    skip_before_action :verify_signed_out_user, only: :destroy

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with_authentication_token(resource)
    end

    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      yield if block_given?
      respond_to_on_destroy
    end

    private

    def respond_with_authentication_token(resource)
      token = JwtService.encode(user_id: resource.id)
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          id: resource.id,
          email: resource.email,
          token:
        }
      }
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
