# frozen_string_literal: true

class AddIndexToFederatedLoginEvent < ActiveRecord::Migration[5.0]
  def change
    add_index :federated_login_events, %i[result timestamp]
  end
end
