# frozen_string_literal: true

class AutomatedReportSubscription < ApplicationRecord
  belongs_to :subject
  belongs_to :automated_report

  valhammer

  validates :identifier, format: /\A[a-zA-Z0-9_-]+\z/
end
