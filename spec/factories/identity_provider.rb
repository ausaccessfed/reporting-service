FactoryGirl.define do
  factory :identity_provider do
    organization

    transient do
      sequence(:domain) do |s|
        Faker::Internet.domain_name + s.to_s
      end
    end

    entity_id { "https://idp.#{domain}/idp/shibboleth" }
    name { "#{Faker::Company.name} #{Faker::Company.suffix} IdP" }
  end
end
