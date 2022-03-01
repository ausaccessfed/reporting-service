# frozen_string_literal: true

FactoryBot.define do
  factory :saml_attribute do
    name { Faker::Lorem.sentence.camelize }
    description { Faker::Lorem.sentence }
    core { false }

    trait :core_attribute do
      core { true }
    end
  end
end
