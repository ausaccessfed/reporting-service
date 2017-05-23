# frozen_string_literal: true

FactoryGirl.define do
  factory :organization do
    identifier { SecureRandom.hex }
    name { Faker::Lorem.sentence }
  end
end
