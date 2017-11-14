# frozen_string_literal: true

class CreateAttributes < ActiveRecord::Migration[4.2]
  def change
    create_table :attributes do |t|
      t.string :name, :description, null: false
      t.timestamps null: false
    end
  end
end
