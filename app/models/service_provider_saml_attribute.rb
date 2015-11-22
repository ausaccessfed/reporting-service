class ServiceProviderSAMLAttribute < ActiveRecord::Base
  belongs_to :service_provider
  belongs_to :saml_attribute

  valhammer

  scope :service_provider_attribute_joint, lambda { |sp, attribute|
    find_by(service_provider: sp, saml_attribute: attribute)
  }
end
