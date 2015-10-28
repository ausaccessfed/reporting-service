FactoryGirl.define do
  factory :activation do
    association :federation_object, factory: :identity_provider

    activated_at { (1..100).to_a.sample.weeks.ago }

    trait :deactivated do
      deactivated_at { 1.day.ago }
    end
  end
end
