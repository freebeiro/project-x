# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_user) { build(:user) }
  let(:underage_user) { build(:user, date_of_birth: 15.years.ago) }
  let(:user_without_dob) { build(:user, date_of_birth: nil) }

  it 'is valid with valid attributes' do
    expect(valid_user).to be_valid
  end

  it 'is not valid without a date of birth' do
    expect(user_without_dob).not_to be_valid
  end

  it 'is not valid if younger than 16' do
    expect(underage_user).not_to be_valid
  end

  it 'has the correct error message for underage users' do
    underage_user = build(:user, date_of_birth: 17.years.ago)
    underage_user.valid?
    expect(underage_user.errors[:date_of_birth]).to include('You should be over 18 years old.')
  end
end
