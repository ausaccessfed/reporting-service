# frozen_string_literal: true

FactoryBot.define do
  factory :identity_provider do
    organization

    transient { sequence(:domain) { |s| Faker::Internet.domain_name + s.to_s } }

    entity_id { "https://idp.#{domain}/idp/shibboleth" }
    name { "#{Faker::Company.name} #{Faker::Company.suffix} IdP" }
  end
end
