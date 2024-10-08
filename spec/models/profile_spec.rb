# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user) { create(:user) }
  let(:profile) { build(:profile, user:) }

  it 'is valid with valid attributes' do
    expect(profile).to be_valid
  end

  it 'is not valid without a first name' do
    profile.first_name = nil
    expect(profile).not_to be_valid
  end

  it 'is not valid without a last name' do
    profile.last_name = nil
    expect(profile).not_to be_valid
  end

  it 'is not valid without an age' do
    profile.age = nil
    expect(profile).not_to be_valid
  end

  it 'is not valid with an age less than 18' do
    profile.age = 17
    expect(profile).not_to be_valid
  end

  it 'is not valid without a username' do
    profile.username = nil
    expect(profile).not_to be_valid
  end

  it 'is not valid with a duplicate username' do
    create(:profile, username: 'testuser')
    profile.username = 'testuser'
    expect(profile).not_to be_valid
  end

  it 'is not valid without an occupation' do
    profile.occupation = nil
    expect(profile).not_to be_valid
  end

  it 'is valid with a description up to 1000 characters' do
    profile.description = 'a' * 1000
    expect(profile).to be_valid
  end

  it 'is not valid with a description over 1000 characters' do
    profile.description = 'a' * 1001
    expect(profile).not_to be_valid
  end
end
