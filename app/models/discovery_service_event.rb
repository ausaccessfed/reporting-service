class DiscoveryServiceEvent < ActiveRecord::Base
  valhammer

  scope :within_range, lambda { |start, finish|
    where(arel_table[:timestamp].gteq(start)
      .and(arel_table[:timestamp].lteq(finish)))
  }

  scope :sessions, -> { where(arel_table[:phase].eq('response')) }
end
