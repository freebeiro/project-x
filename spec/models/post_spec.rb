# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:event) { create(:event, group:) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:event) }
  end

  describe 'validations' do
    context 'with content only' do
      subject { build(:post, user:, group:, event:, content: 'Some text', images: []) }

      it { is_expected.to be_valid }
    end

    # --- Image tests remain pending ---
    context 'with image only' do
      pending 'is valid with image and no content (requires fixture setup)'
    end

    context 'with both content and image' do
      pending 'is valid with both content and image (requires fixture setup)'
    end
    # --- End Pending Image tests ---

    context 'with neither content nor image' do
      let(:post_without_content_or_image) do
        build(:post, user:, group:, event:, content: nil, images: [])
      end

      it 'is not valid' do
        expect(post_without_content_or_image).not_to be_valid
      end

      it 'has errors on content' do
        post_without_content_or_image.valid?
        expect(post_without_content_or_image.errors[:content]).to include("can't be blank")
      end

      it 'has errors on images' do
        post_without_content_or_image.valid?
        expect(post_without_content_or_image.errors[:images]).to include("can't be blank")
      end
    end

    it 'is invalid without user' do
      post = build(:post, user: nil, group:, event:, content: 't')
      expect(post).not_to be_valid
    end

    it 'is invalid without group' do
      post = build(:post, user:, group: nil, event:, content: 't')
      expect(post).not_to be_valid
    end

    it 'is invalid without event' do
      post = build(:post, user:, group:, event: nil, content: 't')
      expect(post).not_to be_valid
    end
  end
end
