require 'rails_helper'

RSpec.describe CreateAutomatedReportInstances do
  include Mail::Matchers

  around { |spec| Timecop.freeze { spec.run } }

  (1..12).each do |time|
    t = format('%02d', time.to_s)

    let("time_#{t}".to_sym) do
      Time.zone.parse("2016-#{t}-01")
    end
  end

  let(:user_01) { create :subject }
  let(:user_02) { create :subject }
  let(:idp) { create :identity_provider }

  let(:opts) do
    { base_url: 'https://test.example.com' }
  end

  %w(monthly quarterly yearly).each do |i|
    let!("auto_report_#{i}_01".to_sym) do
      create :automated_report,
             interval: i,
             report_class: 'DailyDemandReport'
    end

    let!("auto_report_#{i}_02".to_sym) do
      create :automated_report,
             interval: i,
             report_class: 'IdentityProviderDailyDemandReport',
             target: idp.entity_id
    end
  end

  before do
    create :automated_report_subscription,
           automated_report: auto_report_monthly_01,
           subject: user_01

    create :automated_report_subscription,
           automated_report: auto_report_quarterly_01,
           subject: user_01

    create :automated_report_subscription,
           automated_report: auto_report_yearly_01,
           subject: user_01

    create :automated_report_subscription,
           automated_report: auto_report_monthly_02,
           subject: user_02

    create :automated_report_subscription,
           automated_report: auto_report_quarterly_02,
           subject: user_02

    create :automated_report_subscription,
           automated_report: auto_report_yearly_02,
           subject: user_02
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

        expect(instances)
          .to match_array(instance_array + instance_array)
      end
    end
  end

  context 'send email' do
    it 'shoudl send email with subject' do
      email_subject = 'AAF Reporting Service - New Report Generated'

      Timecop.travel(time_01) do
        subject.perform

        [user_01, user_02].each do |subscriber|
          expect(nil).to have_sent_email
            .to(subscriber.mail)
            .matching_subject(email_subject)
        end
      end
    end
  end

  context 'perform' do
    it 'includes automated reports with
        correct interval and with subscribers only' do
      Timecop.travel(time_01) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(6)
      end

      Timecop.travel(time_01 + 5.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_02) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_02 + 10.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_03) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_03 + 20.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_04) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(4)
      end

      Timecop.travel(time_04 + 1.hour) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_05) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_05 + 2.hours) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_06) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_06 + 3.hours) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_07) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(4)
      end
      Timecop.travel(time_07 + 4.hours) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_08) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_08 + 5.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_09) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_09 + 10.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_10) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(4)
      end

      Timecop.travel(time_10 + 20.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_11) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_11 + 1.hour) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end

      Timecop.travel(time_12 + 10.hours) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(2)
      end

      Timecop.travel(time_12 + 11.hours + 59.minutes) do
        expect { subject.perform }
          .not_to change { AutomatedReportInstance.count }
      end
    end
  end
end
