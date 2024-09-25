class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :date_of_birth)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        user: resource,
        token: JWT.encode({ user_id: resource.id }, Rails.application.secrets.secret_key_base)
      }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
