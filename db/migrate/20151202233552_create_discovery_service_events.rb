class CreateDiscoveryServiceEvents < ActiveRecord::Migration
  def change
    create_table :discovery_service_events do |t|
      t.string :user_agent, null: false
      t.string :ip, null: false
      t.string :initiating_sp, null: false
      t.string :group, null: false
      t.string :phase, null: false
      t.string :unique_id, null: false

      t.datetime :timestamp, null: false

      t.string :selection_method
      t.string :return_url
      t.string :selected_idp

      t.timestamps null: false
    end
  end
end
