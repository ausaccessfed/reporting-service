# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AutomatedReportSubscription, type: :model do
  subject { build(:automated_report_subscription) }

  it { is_expected.to validate_presence_of(:automated_report) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_uniqueness_of(:identifier) }

  it 'requires a valid identifier' do
    expect(subject).to allow_value('abcdef_-').for(:identifier)
    expect(subject).not_to allow_value('abcdef_@').for(:identifier)
  end
end
