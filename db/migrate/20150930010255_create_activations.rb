class CreateActivations < ActiveRecord::Migration
  def change
    create_table :activations do |t|
      t.belongs_to :federation_object, polymorphic: true, null: false

      t.timestamp :activated_at, null: false
      t.timestamp :deactivated_at, null: true

      t.timestamps null: false
    end
  end
end
