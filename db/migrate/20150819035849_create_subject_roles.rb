class CreateSubjectRoles < ActiveRecord::Migration
  def change
    create_table :subject_roles do |t|
      t.belongs_to :subject, null: false
      t.belongs_to :role, null: false

      t.timestamps null: false

      t.foreign_key :subjects
      t.foreign_key :roles
      t.index [:subject_id, :role_id], unique: true
    end
  end
end
