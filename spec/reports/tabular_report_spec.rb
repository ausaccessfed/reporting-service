# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TabularReport do
  let(:klass) do
    Class.new(TabularReport) do
      attr_reader :rows

      report_type 'test-table'

      header ['Column 1', 'Column 2', 'Column 3']
      footer ['Footer 1', 'Footer 2', 'Footer 3']

      def initialize(title, rows)
        super(title)
        @rows = rows
      end
    end
  end

  let(:title) { Faker::Lorem.sentence }
  let(:report_rows) { (1..10).to_a.map { Faker::Lorem.words(number: 3) } }
  let(:report) { klass.new(title, report_rows) }

  context '::options' do
    context 'when subclassed' do
      let(:subclass) do
        Class.new(klass) do
          report_type 'subclass-table'

          header ['Column A', 'Column B']
          footer
        end
      end

      let(:subclass_report) do
        subclass.new(title, subclass_report_rows)
      end

      let(:subclass_report_rows) { (1..20).to_a.map { Faker::Lorem.words(number: 2) } }

      it 'has a separate options hash' do
        expect(subclass_report.generate).to include(type: 'subclass-table')
        expect(report.generate).to include(type: 'test-table')
      end

      it 'overrides options in the build' do
        expect(subclass_report.generate[:header])
          .to contain_exactly(['Column A', 'Column B'])
        expect(report.generate[:header])
          .to contain_exactly(['Column 1', 'Column 2', 'Column 3'])
      end
    end
  end

  context '#generate' do
    subject { report.generate }
    let(:header) { [['Column 1', 'Column 2', 'Column 3']] }
    let(:footer) { [['Footer 1', 'Footer 2', 'Footer 3']] }

    it { is_expected.to include(title: title) }
    it { is_expected.to include(rows: report_rows) }
    it { is_expected.to include(type: 'test-table') }
    it { is_expected.to include(header: header) }
    it { is_expected.to include(footer: footer) }
  end
end
