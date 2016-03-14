FactoryGirl.define do
  factory :federated_login_event do
    transient do
      sequence(:domain_idp) do |s|
        Faker::Internet.domain_name + s.to_s
      end

      sequence(:domain_sp) do |s|
        Faker::Internet.domain_name + s.to_s
      end
    end

    relying_party { "https://idp.#{domain_idp}/idp/shibboleth" }
    asserting_party { "https://sp.#{domain_sp}/sp/shibboleth" }
    result { 'OK' }
    timestamp { Time.zone.now }
    hashed_principal_name { SecureRandom.urlsafe_base64 }
  end
end
