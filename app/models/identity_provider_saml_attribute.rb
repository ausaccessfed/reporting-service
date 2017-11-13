# frozen_string_literal: true

class IdentityProviderSAMLAttribute < ApplicationRecord
  belongs_to :identity_provider
  belongs_to :saml_attribute

  valhammer

  validates :saml_attribute_id, uniqueness: { scope: :identity_provider_id }
end
