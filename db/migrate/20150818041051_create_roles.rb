class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :entitlement, null: false
      t.timestamps

      t.index :entitlement, unique: true
    end
  end
end
