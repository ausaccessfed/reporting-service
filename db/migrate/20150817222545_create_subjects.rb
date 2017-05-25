# frozen_string_literal: true

class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :targeted_id, null: false
      t.string :shared_token, null: false
      t.string :name, null: false
      t.string :mail, null: false

      t.boolean :enabled, null: false, default: true
      t.boolean :complete, null: false, default: true

      t.timestamps null: false

      t.index :targeted_id, unique: true
      t.index :shared_token, unique: true
    end
  end
end
