class DiscoveryServiceEvent < ActiveRecord::Base
  belongs_to :service_provider
  belongs_to :identity_provider

  valhammer

  scope :within_range, lambda { |start, finish|
    where((arel_table[:timestamp].gteq(start))
      .and(arel_table[:timestamp].lteq(finish))
      .and(arel_table[:phase].eq('response')))
  }
end
