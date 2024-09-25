# frozen_string_literal: true

# Base controller for the application
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
end
