# frozen_string_literal: true

FactoryBot.define do
  factory :activation do
    transient { base_time { Time.now.utc } }

    federation_object factory: %i[identity_provider]

    activated_at { (36..52).to_a.sample.weeks.until(base_time) }

    trait :deactivated do
      deactivated_at { (1..36).to_a.sample.weeks.until(Time.now.utc) }
    end
  end
end
