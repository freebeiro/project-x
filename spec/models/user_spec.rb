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

  context 'when younger than 16' do
    it 'is not valid' do
      expect(underage_user).not_to be_valid
    end

    it 'has the correct error message' do
      underage_user.valid? # Trigger validation
      expect(underage_user.errors[:date_of_birth]).to include('You must be at least 16 years old.')
    end
  end

  it 'is valid if exactly 16 years old' do
    # Test the boundary condition: exactly 16 years old today
    sixteen_years_ago = 16.years.ago.to_date
    user_at_boundary = build(:user, date_of_birth: sixteen_years_ago)
    expect(user_at_boundary).to be_valid
  end

  context 'when just under 16 years old' do
    # Test the boundary condition: one day less than 16 years old
    let(:dob_slightly_underage) { (16.years.ago + 1.day).to_date }
    let(:user_slightly_underage) { build(:user, date_of_birth: dob_slightly_underage) }

    it 'is not valid' do
      expect(user_slightly_underage).not_to be_valid
    end

    it 'has the correct error message' do
      user_slightly_underage.valid? # Trigger validation
      expect(user_slightly_underage.errors[:date_of_birth]).to include('You must be at least 16 years old.')
    end
  end
end
