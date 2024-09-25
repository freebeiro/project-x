require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = User.new(
      email: 'test@example.com',
      password: 'password',
      date_of_birth: 20.years.ago
    )
    expect(user).to be_valid
  end

  it 'is not valid without a date of birth' do
    user = User.new(
      email: 'test@example.com',
      password: 'password'
    )
    expect(user).to_not be_valid
  end

  it 'is not valid if younger than 16' do
    user = User.new(
      email: 'test@example.com',
      password: 'password',
      date_of_birth: 15.years.ago
    )
    expect(user).to_not be_valid
    expect(user.errors[:date_of_birth]).to include('You must be 16 years or older.')
  end
end
