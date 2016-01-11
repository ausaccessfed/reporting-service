require 'rails_helper'

RSpec.describe AutomatedReportInstance, type: :model do
  subject { build(:automated_report_instance) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:automated_report) }
    it { is_expected.to validate_presence_of(:range_start) }

    it 'requires a UTC timestamp with time set to 00:00:00' do
      time = Time.zone.parse('2015-01-01T00:00:00Z')
      expect(subject).to allow_value(time).for(:range_start)

      zone = Time.find_zone('Australia/Brisbane')

      time = zone.parse('2015-01-01T00:00:00+10:00')
      expect(subject).not_to allow_value(time).for(:range_start)

      # Time zone conversation happens implicitly
      time = zone.parse('2015-01-01T10:00:00+10:00')
      expect(subject).to allow_value(time).for(:range_start)
    end
  end
end
