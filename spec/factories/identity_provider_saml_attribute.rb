# frozen_string_literal: true

FactoryBot.define do
  factory :identity_provider_saml_attribute do
    identity_provider
    saml_attribute
  end
end
