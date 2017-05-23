# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :role, null: false

      t.string :value, null: false

      t.timestamps

      t.foreign_key :roles
      t.index %i[role_id value], unique: true
    end
  end
end
