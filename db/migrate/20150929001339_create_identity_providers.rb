class CreateIdentityProviders < ActiveRecord::Migration
  def change
    create_table :identity_providers do |t|
      t.string :entity_id, :name, null: false
      t.timestamps null: false
    end
  end
end
