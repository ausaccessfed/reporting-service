class SAMLAttribute < ActiveRecord::Base
  has_many :service_provider_saml_attributes
  has_many :service_providers,
           through: :service_provider_saml_attributes

  valhammer
end
