require 'rails_helper'

RSpec.describe CreateAutomatedReportInstances do
  around { |spec| Timecop.freeze { spec.run } }

  let(:start_time) { Time.zone.parse('2016-01-04') }

  let(:user) { create :subject }

  INTERVALS = %w(monthly quarterly yearly).freeze

  INTERVALS.each do |i|
    let!("auto_report_#{i}".to_sym) do
      create :automated_report,
             interval: i,
             report_class: 'DailyDemandReport'
    end
  end

  before do
    create :automated_report_subscription,
           automated_report: auto_report_monthly,
           subject: user
  end

  subject { CreateAutomatedReportInstances.new }

  context 'perform' do
    it 'includes automated reports with subscribers only' do
      expect { subject.perform }
        .to change { AutomatedReportInstance.count }
        .from(0).to(1)
    end
  end
end
