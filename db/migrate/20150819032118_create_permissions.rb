class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.belongs_to :role, null: false

      t.string :value, null: false

      t.timestamps

      t.index [:role_id, :value], unique: true
    end
  end
end
