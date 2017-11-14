# frozen_string_literal: true

class AddCoreToSAMLAttributes < ActiveRecord::Migration[4.2]
  def change
    add_column :saml_attributes, :core, :boolean, null: false
  end
end
