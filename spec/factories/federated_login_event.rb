# frozen_string_literal: true

FactoryBot.define do
  factory :federated_login_event do
    hashed_principal_name { Faker::Internet.password(10) }
    result { 'FAIL' }
    relying_party do
      "https://sp.#{Faker::Internet.domain_name}/shibboleth"
    end

    asserting_party do
      "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth"
    end

    timestamp do
      Faker::Time.between(10.days.ago, Time.zone.today, :day)
    end

    trait :OK do
      result { 'OK' }
    end
  end
end
