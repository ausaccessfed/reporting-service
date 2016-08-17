# frozen_string_literal: true
class AutomatedReportSubscription < ActiveRecord::Base
  belongs_to :subject
  belongs_to :automated_report

  valhammer

  validates :identifier, format: /\A[a-zA-Z0-9_-]+\z/
end
