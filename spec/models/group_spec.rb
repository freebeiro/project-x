# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      name: 'Test Group',
      description: 'A test group',
      privacy: 'public',
      member_limit: 10,
      admin: user
    }
  end

  it 'is valid with valid attributes' do
    group = described_class.new(valid_attributes)
    expect(group).to be_valid
  end

  it 'is not valid without a name' do
    group = described_class.new(name: nil)
    expect(group).not_to be_valid
  end

  it 'is not valid with an invalid privacy setting' do
    group = described_class.new(privacy: 'invalid')
    expect(group).not_to be_valid
  end

  it 'is not valid with a non-positive member limit' do
    group = described_class.new(member_limit: 0)
    expect(group).not_to be_valid
  end

  it 'belongs to an admin' do
    association = described_class.reflect_on_association(:admin)
    expect(association.macro).to eq :belongs_to
  end

  it 'has many group memberships' do
    association = described_class.reflect_on_association(:group_memberships)
    expect(association.macro).to eq :has_many
  end

  it 'has many users through group memberships' do
    association = described_class.reflect_on_association(:users)
    expect(association).not_to be_nil
  end

  it 'has users association with has_many macro' do
    association = described_class.reflect_on_association(:users)
    expect(association.macro).to eq :has_many
  end

  it 'has users association through group_memberships' do
    association = described_class.reflect_on_association(:users)
    expect(association.options[:through]).to eq :group_memberships
  end

  it 'has many members as an alias for users' do
    association = described_class.reflect_on_association(:members)
    expect(association).not_to be_nil
  end

  it 'has members association with has_many macro' do
    association = described_class.reflect_on_association(:members)
    expect(association.macro).to eq :has_many
  end

  it 'has members association through group_memberships' do
    association = described_class.reflect_on_association(:members)
    expect(association.options[:through]).to eq :group_memberships
  end

  it 'has members association with user as source' do
    association = described_class.reflect_on_association(:members)
    expect(association.options[:source]).to eq :user
  end
end
