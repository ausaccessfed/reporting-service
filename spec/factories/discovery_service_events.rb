FactoryGirl.define do
  factory :discovery_service_event do
    transient { domain { Faker::Internet.domain_name } }

    user_agent { 'Mozilla/5.0' }
    ip { Faker::Internet.ip_v4_address }
    initiating_sp { "https://#{domain}.aaf.edu.au/shibboleth" }
    group { Faker::Lorem.word }
    unique_id { Faker::Internet.password(10) }
    phase { 'request' }
    timestamp { Faker::Time.between(40.days.ago, Time.zone.now, :all) }

    trait :response do
      transient { domain { Faker::Internet.domain_name } }
      phase { 'response' }
      selection_method { %w(manual cookie).sample }
      selected_idp { "https://#{domain}.test.aaf.edu.au/idp/shibboleth" }
    end
  end
end
