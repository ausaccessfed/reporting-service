# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :identifier, :name, null: false

      t.timestamps null: false
    end
  end
end
