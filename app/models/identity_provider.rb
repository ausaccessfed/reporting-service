class IdentityProvider < ActiveRecord::Base
  include FederationObject

  has_many :activations, as: :federation_object
  has_many :identity_provider_saml_attributes
  has_many :saml_attributes,
           through: :identity_provider_saml_attributes

  has_many :discovery_service_events

  valhammer
end
