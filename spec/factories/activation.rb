FactoryGirl.define do
  factory :activation do
    transient { base_time { Time.now.utc } }

    association :federation_object, factory: :identity_provider

    activated_at { (1..100).to_a.sample.weeks.until(base_time) }

    trait :deactivated do
      deactivated_at { 1.day.until(base_time) }
    end

    trait :old do
      transient { base_time { 1.year.ago } }
    end
  end
end
