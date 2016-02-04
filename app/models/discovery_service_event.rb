class DiscoveryServiceEvent < ActiveRecord::Base
  valhammer

  belongs_to :identity_provider,
             foreign_key: :selected_idp,
             primary_key: :entity_id

  belongs_to :service_provider,
             foreign_key: :initiating_sp,
             primary_key: :entity_id

  scope :within_range, lambda { |start, finish|
    where(arel_table[:timestamp].gteq(start)
      .and(arel_table[:timestamp].lteq(finish)))
  }

  scope :sessions, -> { where(arel_table[:phase].eq('response')) }
end
