# frozen_string_literal: true

class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.string :name, :description, null: false

      t.timestamps null: false
    end
  end
end
