class AutomatedReportSubscription < ActiveRecord::Base
  belongs_to :subject
  belongs_to :automated_report

  valhammer
end
