class RefactorDiscoveryServiceEventForeignKeys < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :discovery_service_events, :initiating_sp, :string
        add_column :discovery_service_events, :selected_idp, :string

        execute %(
          update discovery_service_events dse
          join service_providers sp
            on dse.service_provider_id = sp.id
          left outer join identity_providers idp
            on dse.identity_provider_id = idp.id
          set dse.initiating_sp = sp.entity_id,
            dse.selected_idp = idp.entity_id
        )

        change_column :discovery_service_events, :initiating_sp, :string,
                      null: false

        remove_foreign_key :discovery_service_events, :service_providers
        remove_column :discovery_service_events, :service_provider_id

        remove_foreign_key :discovery_service_events, :identity_providers
        remove_column :discovery_service_events, :identity_provider_id
      end

      dir.down do
        add_column :discovery_service_events, :service_provider_id, :integer
        add_foreign_key :discovery_service_events, :service_providers
        add_column :discovery_service_events, :identity_provider_id, :integer
        add_foreign_key :discovery_service_events, :identity_providers

        execute %(
          update discovery_service_events dse
          join service_providers sp
            on dse.initiating_sp = sp.entity_id
          left outer join identity_providers idp
            on dse.selected_idp = idp.entity_id
          set dse.service_provider_id = sp.id,
             dse.identity_provider_id = idp.id
        )

        change_column :discovery_service_events, :service_provider_id, :integer,
                      null: false

        remove_column :discovery_service_events, :initiating_sp
        remove_column :discovery_service_events, :selected_idp
      end
    end
  end
end
