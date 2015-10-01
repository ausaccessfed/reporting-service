FactoryGirl.define do
  factory :service_provider do
    transient { domain { Faker::Internet.domain_name } }

    entity_id { "https://sp.#{domain}/shibboleth" }
    name { "#{domain} SP" }
  end
end
