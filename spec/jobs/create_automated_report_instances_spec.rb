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
    it 'should send email with subject' do
      email_subject = 'AAF Reporting Service - New Report Generated'

      Timecop.travel(time_01) do
        subject.perform

        [user_01, user_02].each do |subscriber|
          expect(nil).to have_sent_email
            .to(subscriber.mail).matching_subject(email_subject)
        end
      end
    end
  end

  context 'perform' do
    it 'creates monthly, quarterly and yearly instances
        at beginning of each year' do
      Timecop.travel(time_01) do
        expect { subject.perform }
          .to change(AutomatedReportInstance, :count).by(6)
      end

      5.times do |i|
        Timecop.travel(time_01 + i.hours) do
          expect { subject.perform }
            .not_to change { AutomatedReportInstance.count }
        end
      end
    end

    it 'creates monthly and quarterly instances on
        April, July and October' do
      [time_04, time_07, time_10].each do |time|
        time_pass = [50, 10, 30].sample.minutes

        Timecop.travel(time) do
          expect { subject.perform }
            .to change(AutomatedReportInstance, :count).by(4)
        end

        Timecop.travel(time + time_pass) do
          expect { subject.perform }
            .not_to change { AutomatedReportInstance.count }
        end
      end
    end

    it 'creates only monthly instances' do
      [time_02, time_03, time_05,
       time_06, time_08, time_09, time_11, time_12].each do |time|
        time_pass = [*1..12].sample.hours

        Timecop.travel(time) do
          expect { subject.perform }
            .to change(AutomatedReportInstance, :count).by(2)
        end

        Timecop.travel(time + time_pass) do
          expect { subject.perform }
            .not_to change { AutomatedReportInstance.count }
        end
      end
    end
  end
end
