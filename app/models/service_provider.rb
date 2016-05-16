class ServiceProvider < ActiveRecord::Base
  include FederationObject

  belongs_to :organization

  has_many :activations, as: :federation_object
  has_many :service_provider_saml_attributes
  has_many :saml_attributes,
           through: :service_provider_saml_attributes

  valhammer

  def self.find_by_identifying_attribute(value)
    find_by(entity_id: value)
  end
end
