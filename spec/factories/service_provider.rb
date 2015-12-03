FactoryGirl.define do
  factory :service_provider do
    transient do
      sequence(:domain) do |s|
        "Faker::Internet.domain_name#{s}"
      end
    end

    entity_id { "https://sp.#{domain}/shibboleth" }
    name { "#{domain} SP" }
  end
end
