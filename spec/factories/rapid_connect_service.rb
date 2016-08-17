# frozen_string_literal: true
FactoryGirl.define do
  factory :rapid_connect_service do
    organization

    identifier { SecureRandom.urlsafe_base64 }
    name { Faker::Lorem.sentence }
    service_type { 'research' }
  end
end
