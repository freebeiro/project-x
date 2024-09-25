# frozen_string_literal: true

# Base controller for the application
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  respond_to :json
end
