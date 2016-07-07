# frozen_string_literal: true
FactoryGirl.define do
  factory :service_provider_saml_attribute do
    service_provider
    saml_attribute

    optional { true }
  end
end
