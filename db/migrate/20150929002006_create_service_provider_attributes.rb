# frozen_string_literal: true

class CreateServiceProviderAttributes < ActiveRecord::Migration
  def change
    create_table :service_provider_attributes do |t|
      t.belongs_to :service_provider, :attribute, null: false
      t.boolean :optional, null: false
      t.timestamps null: false

      t.foreign_key :service_providers
      t.foreign_key :attributes

      t.index %i[service_provider_id attribute_id],
              unique: true, name: 'unique_service_provider_attribute'
    end
  end
end
