class CreateAPISubjectRoles < ActiveRecord::Migration
  def change
    create_table :api_subject_roles do |t|
      t.belongs_to :api_subject, null: false
      t.belongs_to :role, null: false

      t.timestamps

      t.foreign_key :api_subjects
      t.foreign_key :roles
      t.index [:api_subject_id, :role_id], unique: true
    end
  end
end
