# frozen_string_literal: true

# This migration comes from active_storage (originally 20170806125915)
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
class CreateActiveStorageTables < ActiveRecord::Migration[5.2]
  def change
    create_table :active_storage_blobs, id: :primary_key do |t|
      t.string   :key,          null: false
      t.string   :filename,     null: false
      t.string   :content_type
      t.text     :metadata
      t.string   :service_name, null: false
      t.bigint   :byte_size,    null: false
      t.string   :checksum

      if connection.supports_datetime_with_precision?
        t.datetime :created_at, precision: 6, null: false
      else
        t.datetime :created_at, null: false
      end

      t.index [:key], unique: true
    end

    create_table :active_storage_attachments, id: :primary_key do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      if connection.supports_datetime_with_precision?
        t.datetime :created_at, precision: 6, null: false
      else
        t.datetime :created_at, null: false
      end

      t.index %i[record_type record_id name blob_id], name: :index_active_storage_attachments_uniqueness, unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end

    create_table :active_storage_variant_records, id: :primary_key do |t|
      t.belongs_to :blob, null: false, index: false
      t.string :variation_digest, null: false

      t.index %i[blob_id variation_digest], name: :index_active_storage_variant_records_uniqueness, unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
  end

  private

  def primary_key_type
    config = Rails.application.config.active_record
    setting = config.try(:schema_format) == :sql ? :primary_key_type : :primary_key
    config.try(setting) || :primary_key
  end

  def foreign_key_type
    primary_key_type == :uuid ? :uuid : :bigint
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
