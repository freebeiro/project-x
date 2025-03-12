# frozen_string_literal: true

# Require the JWT gem
require 'jwt'

# Store the JWT secret key in a global constant
# Try to get from ENV first, fallback to hardcoded only for development/test
JWT_SECRET_KEY = ENV['JWT_SECRET_KEY'] || '0bc347d905b7d9e4afd9395b8e9b3dc56646d6fc6205413d3f537dada4c978152d4' \
                                          'f53eb08138cafeaafc577df724ad8e43114a12130463a93874180a84a6c4e'
