FactoryGirl.define do
  factory :discovery_service_event do
<<<<<<< HEAD
    service_provider

    user_agent { 'Mozilla/5.0' }
    ip { Faker::Internet.ip_v4_address }
=======
    transient { domain { Faker::Internet.domain_name } }

    user_agent { 'Mozilla/5.0' }
    ip { Faker::Internet.ip_v4_address }
    initiating_sp { "https://#{domain}.aaf.edu.au/shibboleth" }
>>>>>>> 896b191c8c12d6e421762c347a9eeeade1a653c5
    group { Faker::Lorem.word }
    unique_id { Faker::Internet.password(10) }
    phase { 'request' }
    timestamp { Faker::Time.between(40.days.ago, Time.zone.now, :all) }

    trait :response do
<<<<<<< HEAD
      identity_provider

      phase { 'response' }
      selection_method { %w(manual cookie).sample }
=======
      transient { domain { Faker::Internet.domain_name } }
      phase { 'response' }
      selection_method { %w(manual cookie).sample }
      selected_idp { "https://#{domain}.test.aaf.edu.au/idp/shibboleth" }
>>>>>>> 896b191c8c12d6e421762c347a9eeeade1a653c5
    end
  end
end
