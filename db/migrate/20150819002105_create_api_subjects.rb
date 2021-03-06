# frozen_string_literal: true

class CreateAPISubjects < ActiveRecord::Migration[4.2]
  def change
    create_table :api_subjects do |t|
      t.string :x509_cn, null: false
      t.string :contact_name, null: false
      t.string :contact_mail, null: false
      t.string :description, null: false
      t.boolean :enabled, null: false, default: true

      t.timestamps

      t.index :x509_cn, unique: true
    end
  end
end
