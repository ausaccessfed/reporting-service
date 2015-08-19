class CreateAPISubjects < ActiveRecord::Migration
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
