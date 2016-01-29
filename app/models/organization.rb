class Organization < ActiveRecord::Base
  include FederationObject

  has_many :activations, as: :federation_object
  has_many :identity_providers
  has_many :service_providers
  has_many :rapid_connect_services

  valhammer

  validates :identifier, format: /\A[a-zA-Z0-9_-]+\z/

  def self.find_by_identifying_attribute(value)
    find_by(identifier: value)
  end
end
