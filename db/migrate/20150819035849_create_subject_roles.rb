class CreateSubjectRoles < ActiveRecord::Migration
  def change
    create_table :subject_roles do |t|
      t.belongs_to :subject, null: false
      t.belongs_to :role, null: false

      t.timestamps

      t.index [:subject_id, :role_id], unique: true
    end
  end
end
