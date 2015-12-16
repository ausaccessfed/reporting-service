FactoryGirl.define do
  factory :discovery_service_event do
    service_provider

    user_agent { 'Mozilla/5.0' }
    ip { Faker::Internet.ip_v4_address }
    group { Faker::Lorem.word }
    unique_id { Faker::Internet.password(10) }
    phase { 'request' }
    timestamp do
      Faker::Time.between(10.days.ago.beginning_of_day,
                          1.day.ago.beginning_of_day)
    end

    trait :response do
      identity_provider

      phase { 'response' }
      selection_method { %w(manual cookie).sample }
    end
  end
end
