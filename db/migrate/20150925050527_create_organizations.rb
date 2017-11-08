# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[4.2]
  def change
    create_table :organizations do |t|
      t.string :identifier, :name, null: false
      t.timestamps null: false
    end
  end
end
