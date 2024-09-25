# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  # Extract common setups or tests into shared contexts or examples
  shared_context 'common user session setup' do
    # Move common setup here
  end

  shared_examples 'common session behavior' do
    # Move common tests here
  end

  # Use the shared context and examples in your tests
  describe 'some specific behavior' do
    include_context 'common user session setup'
    it_behaves_like 'common session behavior'

    # Additional specific tests
  end

  # More test groups...
end
