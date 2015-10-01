FactoryGirl.define do
  factory :attribute do
    name { Faker::Lorem.sentence.camelize }
    description { Faker::Lorem.paragraph }
  end
end
