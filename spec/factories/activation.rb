FactoryGirl.define do
  factory :activation do
    association :federation_object, factory: :identity_provider

    activated_at { (1..100).to_a.sample.weeks.ago }
  end
end
