FactoryGirl.define do
  factory :discovery_service_event do
    service_provider

    user_agent { 'Mozilla/5.0' }
    ip { Faker::Internet.ip_v4_address }
    group { Faker::Lorem.word }
    unique_id { Faker::Internet.password(10) }
    phase { 'request' }
    timestamp { Faker::Time.between(40.days.ago, Time.zone.now, :all) }

    trait :response do
      identity_provider

      phase { 'response' }
      selection_method { %w(manual cookie).sample }
    end
  end
end
