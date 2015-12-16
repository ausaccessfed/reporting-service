FactoryGirl.define do
  factory :identity_provider do
    transient do
      sequence(:domain) do |s|
        Faker::Internet.domain_name + s.to_s
      end
    end

    entity_id { "https://idp.#{domain}/idp/shibboleth" }
    name { "#{domain} IdP" }
  end
end
