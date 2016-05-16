FactoryGirl.define do
  factory :permission do
    role

    value { Faker::Lorem.words(4).join(':') }
  end
end
