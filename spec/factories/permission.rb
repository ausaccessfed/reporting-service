# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    role

    value { Faker::Lorem.words(4).join(':') }
  end
end
