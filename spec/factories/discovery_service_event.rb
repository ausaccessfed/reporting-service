# frozen_string_literal: true

FactoryBot.define do
  factory :discovery_service_event do
    user_agent { 'Mozilla/5.0' }
    ip { Faker::Internet.ip_v4_address }
    group { Faker::Lorem.word }
    unique_id { Faker::Internet.password(min_length: 10) }
    phase { 'request' }
    initiating_sp do
      "https://sp.#{Faker::Internet.domain_name}/shibboleth"
    end

    timestamp do
      Faker::Time.between(from: 10.days.ago, to: Time.zone.today).round
    end

    trait :response do
      selected_idp do
        "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth"
      end

      phase { 'response' }
      selection_method { %w[manual cookie].sample }
    end
  end
end
