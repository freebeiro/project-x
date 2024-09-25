# frozen_string_literal: true

module Users
  # RegistrationsController
  # Handles user registration process
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    def create
      build_resource(sign_up_params)
      process_user_registration
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :date_of_birth)
    end

    def process_user_registration
      if resource.save
        handle_successful_registration
      else
        handle_failed_registration
      end
    end

    def handle_successful_registration
      # ... code for successful registration ...
    end

    def handle_failed_registration
      # ... code for failed registration ...
    end
  end
end
