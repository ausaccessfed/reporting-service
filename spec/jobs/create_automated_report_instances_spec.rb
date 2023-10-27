# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateAutomatedReportInstances do
  include Mail::Matchers

  subject { described_class.new }

  around { |spec| Timecop.freeze { spec.run } }

  %w[january february march april may june july august september october november december].each do |month|
    let(month.to_sym) { Time.zone.parse("2016-#{month}-01") }
  end

  let(:user_01) { create(:subject) }
  let(:user_02) { create(:subject) }
  let(:idp) { create(:identity_provider) }

  %w[monthly quarterly yearly].each do |i|
    let!("auto_report_#{i}_01".to_sym) do
      create(:automated_report, interval: i, report_class: 'DailyDemandReport', source: 'DS')
    end

    let!("auto_report_#{i}_02".to_sym) do
      create(
        :automated_report,
        interval: i,
        report_class: 'IdentityProviderDailyDemandReport',
        source: 'DS',
        target: idp.entity_id
      )
    end
  end

  before do
    create(:automated_report_subscription, automated_report: auto_report_monthly_01, subject: user_01)

    create(:automated_report_subscription, automated_report: auto_report_quarterly_01, subject: user_01)

    create(:automated_report_subscription, automated_report: auto_report_yearly_01, subject: user_01)

    create(:automated_report_subscription, automated_report: auto_report_monthly_02, subject: user_02)

    create(:automated_report_subscription, automated_report: auto_report_quarterly_02, subject: user_02)

    create(:automated_report_subscription, automated_report: auto_report_yearly_02, subject: user_02)
  end

  context 'update :instances_timestamp' do
    it 'is equal to begging of correct month' do
      [january, february, march, april, may, june, july, august, september, october, november, december].each do |month|
        Timecop.travel(month) do
          subject.perform

          instance = AutomatedReportInstance.find_by(range_end: month.beginning_of_month)

          timestamp = instance.automated_report.instances_timestamp

          expect(timestamp).to eql(month)
        end
      end
    end
  end

  context 'include range_end' do
    it 'for monthly interval should be from last month' do
      range_end = january.beginning_of_month

      instance_array = [['monthly', range_end], ['quarterly', range_end], ['yearly', range_end]]

      Timecop.travel(january) do
        subject.perform

        instances = AutomatedReportInstance.all.map { |i| [i.automated_report.interval, i.range_end] }

        expect(instances).to match_array(instance_array + instance_array)
      end
    end
  end

  context 'send email' do
    it 'sends email with subject' do
      email_subject = 'AAF Reporting Service - New Report Generated'

      Timecop.travel(january) do
        subject.perform

        [user_01, user_02].each do |subscriber|
          expect(nil).to have_sent_email.to(subscriber.mail).matching_subject(email_subject)
        end
      end
    end
  end

  context 'perform' do
    it 'creates monthly, quarterly and yearly instances
        at beginning of each year' do
      Timecop.travel(january) { expect { subject.perform }.to change(AutomatedReportInstance, :count).by(6) }

      5.times do |i|
        Timecop.travel(january + i.hours) { expect { subject.perform }.not_to(change(AutomatedReportInstance, :count)) }
      end
    end

    it 'creates monthly and quarterly instances on
        April, July and October' do
      [april, july, october].each do |time|
        samples = [50, 10, 30]
        time_pass = samples.sample.minutes

        Timecop.travel(time) { expect { subject.perform }.to change(AutomatedReportInstance, :count).by(4) }

        Timecop.travel(time + time_pass) { expect { subject.perform }.not_to(change(AutomatedReportInstance, :count)) }
      end
    end

    it 'creates only monthly instances' do
      [february, march, may, june, august, september, november, december].each do |time|
        time_pass = [*1..28].sample.days

        Timecop.travel(time) { expect { subject.perform }.to change(AutomatedReportInstance, :count).by(2) }

        Timecop.travel(time + time_pass) { expect { subject.perform }.not_to(change(AutomatedReportInstance, :count)) }
      end
    end
  end
end
