FactoryGirl.define do
  factory :identity_provider do
    transient { domain { Faker::Internet.domain_name } }

    entity_id { "https://idp.#{domain}/idp/shibboleth" }
    name { "#{domain} IdP" }
  end
end
