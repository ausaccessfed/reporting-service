require 'rails_helper'

RSpec.describe AutomatedReportSubscription, type: :model do
  subject { build(:automated_report_subscription) }

  it { is_expected.to validate_presence_of(:automated_report) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_uniqueness_of(:identifier) }
end
