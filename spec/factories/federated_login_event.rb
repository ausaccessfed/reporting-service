# frozen_string_literal: true

FactoryBot.define do
  factory :federated_login_event do
    hashed_principal_name { Faker::Internet.password(min_length: 10) }
    result { 'FAIL' }
    relying_party { "https://sp.#{Faker::Internet.domain_name}/shibboleth" }

    asserting_party { "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth" }

    timestamp { Faker::Time.between(from: 10.days.ago, to: Time.zone.today).round }

    trait :OK do
      result { 'OK' }
    end
  end
end
