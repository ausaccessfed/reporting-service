class DiscoveryServiceEvent < ActiveRecord::Base
  belongs_to :service_provider
  belongs_to :identity_provider

  valhammer
end
