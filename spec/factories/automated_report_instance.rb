# frozen_string_literal: true

FactoryBot.define do
  factory :automated_report_instance do
    automated_report
    range_end { Time.zone.now.beginning_of_month }
    identifier { SecureRandom.urlsafe_base64 }
  end
end
