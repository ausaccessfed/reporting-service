FactoryGirl.define do
  factory :organization do
    identifier { "http://#{Faker::Internet.domain_name}" }
    name { Faker::Lorem.sentence }
  end
end
