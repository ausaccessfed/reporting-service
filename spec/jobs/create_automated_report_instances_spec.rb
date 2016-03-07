require 'rails_helper'

RSpec.describe CreateAutomatedReportInstances do
  around { |spec| Timecop.freeze { spec.run } }

  (1..12).each do |time|
    t = format('%02d', time.to_s)

    let("time_#{t}".to_sym) do
      Time.zone.parse("2016-#{t}-01")
    end
  end

  let(:user) { create :subject }

  %w(monthly quarterly yearly).each do |i|
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

    create :automated_report_subscription,
           automated_report: auto_report_quarterly,
           subject: user

    create :automated_report_subscription,
           automated_report: auto_report_yearly,
           subject: user
  end

  subject { CreateAutomatedReportInstances.new }

  context 'include range_start' do
    it 'for monthly interval should be from last month' do
      start_m = (time_01 - 1.month).beginning_of_month
      start_q = (time_01 - 3.months).beginning_of_month
      start_y = (time_01 - 12.months).beginning_of_month
      instance_array = [['monthly', start_m],
                        ['quarterly', start_q],
                        ['yearly', start_y]]

      Timecop.travel(time_01) do
        subject.perform

        instances = AutomatedReportInstance.all.map do |i|
          [i.automated_report.interval, i.range_start]
        end

        expect(instances).to match_array(instance_array)
      end
    end
  end

  context 'perform' do
    it 'includes automated reports with
        correct interval and with subscribers only' do
      Timecop.travel(time_01) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(0).to(3)
      end

      Timecop.travel(time_02) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(3).to(4)
      end

      Timecop.travel(time_03) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(4).to(5)
      end

      Timecop.travel(time_04) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(5).to(7)
      end

      Timecop.travel(time_05) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(7).to(8)
      end

      Timecop.travel(time_06) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(8).to(9)
      end

      Timecop.travel(time_07) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(9).to(11)
      end

      Timecop.travel(time_08) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(11).to(12)
      end

      Timecop.travel(time_09) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(12).to(13)
      end

      Timecop.travel(time_10) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(13).to(15)
      end

      Timecop.travel(time_11) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(15).to(16)
      end

      Timecop.travel(time_12) do
        expect { subject.perform }
          .to change { AutomatedReportInstance.count }
          .from(16).to(17)
      end
    end
  end
end
