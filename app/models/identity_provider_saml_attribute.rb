class IdentityProviderSAMLAttribute < ActiveRecord::Base
  belongs_to :identity_provider
  belongs_to :saml_attribute

  valhammer
end
