# frozen_string_literal: true

class ServiceProvider < ApplicationRecord
  include FederationObject

  belongs_to :organization

  has_many :activations, as: :federation_object, dependent: :destroy
  has_many :service_provider_saml_attributes, dependent: :destroy
  has_many :saml_attributes, through: :service_provider_saml_attributes, dependent: :destroy

  valhammer

  def self.find_by_identifying_attribute(value)
    find_by(entity_id: value)
  end
end
