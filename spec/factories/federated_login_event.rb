# frozen_string_literal: true

FactoryBot.define do
  factory :federated_login_event do
    hashed_principal_name { Faker::Internet.password(min_length: 10) }
    result { 'FAIL' }
    relying_party do
      "https://sp.#{Faker::Internet.domain_name}/shibboleth"
    end

    asserting_party do
      "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth"
    end

    timestamp do
      Faker::Time.between(from: 10.days.ago, to: Time.zone.today).round
    end

    trait :OK do
      result { 'OK' }
    end
  end
end
