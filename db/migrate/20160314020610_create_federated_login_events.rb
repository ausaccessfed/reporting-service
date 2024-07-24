# frozen_string_literal: true

class CreateFederatedLoginEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :federated_login_events do |t|
      t.string :relying_party, :asserting_party, :result, null: false

      t.string :hashed_principal_name, null: false

      t.timestamp :timestamp, null: false
      t.timestamps null: false

      t.index :hashed_principal_name
    end
  end
end
