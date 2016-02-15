FactoryGirl.define do
  factory :automated_report_instance do
    automated_report
    range_start { 1.month.ago.utc.beginning_of_month }
    identifier { SecureRandom.urlsafe_base64 }
  end
end
