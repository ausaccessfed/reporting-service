FactoryGirl.define do
  factory :automated_report_instance do
    automated_report
    range_start { 1.month.until(Time.now).utc.beginning_of_month }
  end
end
