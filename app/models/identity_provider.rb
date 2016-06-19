# frozen_string_literal: true
class IdentityProvider < ActiveRecord::Base
  include FederationObject

  belongs_to :organization

  has_many :activations, as: :federation_object
  has_many :identity_provider_saml_attributes
  has_many :saml_attributes,
           through: :identity_provider_saml_attributes

  valhammer

  def self.find_by_identifying_attribute(value)
    find_by(entity_id: value)
  end
end
