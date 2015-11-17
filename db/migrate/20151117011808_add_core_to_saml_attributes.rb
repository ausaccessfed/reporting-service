class AddCoreToSAMLAttributes < ActiveRecord::Migration
  def change
    add_column :saml_attributes, :core, :boolean, null: false
  end
end
