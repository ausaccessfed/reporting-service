FactoryGirl.define do
  factory :identity_provider_saml_attribute do
    identity_provider
    saml_attribute
  end
end
