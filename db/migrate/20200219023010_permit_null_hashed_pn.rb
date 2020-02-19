# frozen_string_literal: true

class PermitNullHashedPn < ActiveRecord::Migration[4.2]
  def change
    change_column :federated_login_events, :hashed_principal_name, :string, null: true
  end
end
