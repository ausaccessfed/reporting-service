# frozen_string_literal: true

FactoryBot.define do
  factory :api_subject do
    x509_cn { SecureRandom.urlsafe_base64 }
    contact_name { Faker::Name.name }
    contact_mail { Faker::Internet.email(name: contact_name) }
    description { Faker::Lorem.sentence }

    trait :authorized do
      transient { permission { '*' } }

      after(:create) do |user, attrs|
        role = create(:permission, value: attrs.permission).role
        user.api_subject_roles.create!(role:)
        user.reload
      end
    end
  end
end
