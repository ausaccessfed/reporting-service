FactoryGirl.define do
  factory :organization do
    identifier { SecureRandom.hex }
    name { Faker::Lorem.sentence }
  end
end
