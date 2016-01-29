FactoryGirl.define do
  factory :service_provider do
    organization

    transient do
      sequence(:domain) do |s|
        Faker::Internet.domain_name + s.to_s
      end
    end

    entity_id { "https://sp.#{domain}/shibboleth" }
    name { "#{domain} SP" }
  end
end
