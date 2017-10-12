# frozen_string_literal: true

class SAMLAttribute < ApplicationRecord
  has_many :service_provider_saml_attributes, dependent: :destroy
  has_many :service_providers,
           through: :service_provider_saml_attributes, dependent: :destroy

  valhammer

  def self.find_by_identifying_attribute(value)
    find_by(name: value)
  end
end
