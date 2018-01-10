# frozen_string_literal: true

FactoryBot.define do
  factory :automated_report do
    report_class 'FederationGrowthReport'
    interval 'monthly'
  end
end
