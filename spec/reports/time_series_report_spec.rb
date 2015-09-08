require 'rails_helper'

RSpec.describe TimeSeriesReport do
  let(:klass) do
    Class.new(TimeSeriesReport) do
      attr_reader :data

      report_type 'test-report'

      y_label 'Y Label'

      series a: 'The letter A',
             b: 'The letter B',
             c: 'The letter C'

      units ' Hz'

      def initialize(title, start, finish, data)
        super(title, start, finish)
        @data = data
      end
    end
  end

  let(:title) { Faker::Lorem.sentence }
  let(:start) { 1.week.ago.utc.beginning_of_day }
  let(:finish) { Time.now.utc.beginning_of_day }
  let(:report) { klass.new(title, start, finish, report_data) }

  let(:report_data) do
    {
      a: [
        [0, 0],
        [1, 0],
        [2, 0]
      ],
      b: [
        [0, 1],
        [1, 1],
        [2, 1]
      ],
      c: [
        [0, 2],
        [1, 2],
        [2, 2]
      ]
    }
  end

  context '::options' do
    context 'when subclassed' do
      let(:subclass) do
        Class.new(klass) do
          report_type 'subclass-report'

          series d: 'The letter D'
        end
      end

      let(:subclass_report) { subclass.new(title, start, finish, report_data) }

      it 'has a separate options hash' do
        expect(subclass_report.generate).to include(type: 'subclass-report')
        expect(report.generate).to include(type: 'test-report')
      end

      it 'behaves predictably with nested options' do
        expect(subclass_report.generate[:labels]).to include(d: 'The letter D')
        expect(report.generate[:labels]).not_to include(d: 'The letter D')
      end

      it 'retains options from the parent' do
        expect(subclass_report.generate[:labels]).to include(y: 'Y Label')
      end
    end
  end

  context '#generate' do
    subject { report.generate }

    it { is_expected.to include(title: title) }
    it { is_expected.to include(range: { start: start, end: finish }) }
    it { is_expected.to include(type: 'test-report') }
    it { is_expected.to include(labels: include(y: 'Y Label')) }
    it { is_expected.to include(labels: include(a: 'The letter A')) }
    it { is_expected.to include(labels: include(b: 'The letter B')) }
    it { is_expected.to include(labels: include(c: 'The letter C')) }
    it { is_expected.to include(series: contain_exactly(:a, :b, :c)) }
    it { is_expected.to include(units: ' Hz') }
    it { is_expected.to include(data: report_data) }
  end
end
