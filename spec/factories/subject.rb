FactoryGirl.define do
  factory :subject do
    transient do
      idp { "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth" }
      sp { 'https://reporting.example.edu/shibboleth' }
    end

    targeted_id { "#{idp}!#{sp}!#{SecureRandom.uuid}" }
    shared_token { SecureRandom.urlsafe_base64(19) }
    name { Faker::Name.name }
    mail { Faker::Internet.email(name) }
  end
end
