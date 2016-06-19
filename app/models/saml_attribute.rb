# frozen_string_literal: true
class SAMLAttribute < ActiveRecord::Base
  has_many :service_provider_saml_attributes
  has_many :service_providers,
           through: :service_provider_saml_attributes

  valhammer

  def self.find_by_identifying_attribute(value)
    find_by(name: value)
  end
end
