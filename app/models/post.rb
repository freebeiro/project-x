# frozen_string_literal: true

# Represents a post made within a group for a specific event.
# Can contain text content and attached images.
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :event

  # Allow multiple images per post
  has_many_attached :images

  # Basic validation (content can be blank if images are present, or vice-versa)
  validates :content, presence: true, unless: -> { images.attached? }
  validates :images, presence: true, unless: -> { content.present? }

  # Add validation for image types, size limits etc. if needed
  # validates :images, content_type: ['image/png', 'image/jpg', 'image/jpeg'],
  #                    size: { less_than: 5.megabytes }
end
