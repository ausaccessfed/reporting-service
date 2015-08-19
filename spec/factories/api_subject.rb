FactoryGirl.define do
  factory :api_subject do
    x509_cn { SecureRandom.urlsafe_base64 }
    contact_name { Faker::Name.name }
    contact_mail { Faker::Internet.email(contact_name) }
    description { Faker::Lorem.sentence }
  end
end
