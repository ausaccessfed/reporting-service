FactoryGirl.define do
  factory :rapid_connect_service do
    identifier { SecureRandom.urlsafe_base64 }
    name { Faker::Lorem.sentence }
    type { 'research' }
  end
end
