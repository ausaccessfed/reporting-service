# frozen_string_literal: true

FactoryBot.define do
  factory :service_provider do
    organization

    transient { sequence(:domain) { |s| Faker::Internet.domain_name + s.to_s } }

    entity_id { "https://sp.#{domain}/shibboleth" }
    name { "#{Faker::Company.name} #{Faker::Company.suffix} SP" }
  end
end
