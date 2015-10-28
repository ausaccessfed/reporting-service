FactoryGirl.define do
  factory :rapid_connect_service do
    identifier { SecureRandom.urlsafe_base64 }
    name { Faker::Lorem.sentence }
    service_type { 'research' }
  end
end
