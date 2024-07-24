# frozen_string_literal: true

class ChangeTablesCollationToBinary < ActiveRecord::Migration[4.2]
  TABLES = %w[
    activations
    api_subject_roles
    api_subjects
    automated_report_instances
    automated_report_subscriptions
    automated_reports
    discovery_service_events
    federated_login_events
    identity_provider_saml_attributes
    identity_providers
    incoming_f_ticks_events
    organizations
    permissions
    rapid_connect_services
    roles
    saml_attributes
    service_provider_saml_attributes
    service_providers
    subject_roles
    subjects
  ].freeze

  def change
    TABLES.each do |table|
      execute "ALTER TABLE #{table} COLLATE = utf8_bin"
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER" \
                ' SET utf8 COLLATE utf8_bin'
    end
  end
end
