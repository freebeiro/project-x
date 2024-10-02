# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it 'is valid with valid attributes' do
    profile = build(:profile)
    expect(profile).to be_valid
  end

  it 'is not valid without a name' do
    profile = described_class.new(name: nil)
    expect(profile).not_to be_valid
  end

  it 'is not valid with an age less than 18' do
    profile = described_class.new(age: 17)
    expect(profile).not_to be_valid
  end

  it 'belongs to a user' do
    association = described_class.reflect_on_association(:user)
    expect(association.macro).to eq :belongs_to
  end
end
