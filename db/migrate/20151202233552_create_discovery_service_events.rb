class CreateDiscoveryServiceEvents < ActiveRecord::Migration
  def change
    create_table :discovery_service_events do |t|
      t.string :user_agent, null: false
      t.string :ip, null: false
      t.string :group, null: false
      t.string :phase, null: false
      t.string :unique_id, null: false
      t.datetime :timestamp, null: false

      t.string :selection_method
      t.string :return_url

      t.timestamps null: false

      t.references :service_providers, null: false
      t.references :identity_providers

      t.foriegn_key :identity_providers
      t.foriegn_key :service_providers

      t.index :timestamp
    end
  end
end
