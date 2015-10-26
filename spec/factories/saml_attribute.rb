FactoryGirl.define do
  factory :saml_attribute do
    name { Faker::Lorem.sentence.camelize }
    description { Faker::Lorem.sentence }
  end
end
