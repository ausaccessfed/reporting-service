class CreateIdentityProviderAttributes < ActiveRecord::Migration
  def change
    create_table :identity_provider_attributes do |t|
      t.belongs_to :identity_provider, :attribute, null: false

      t.timestamps null: false

      t.foreign_key :identity_providers
      t.foreign_key :attributes

      t.index [:identity_provider_id, :attribute_id],
              unique: true, name: 'unique_identity_provider_attribute'
    end
  end
end
