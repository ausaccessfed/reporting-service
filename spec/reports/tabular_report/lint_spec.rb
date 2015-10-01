require 'rails_helper'

RSpec.describe TabularReport::Lint do
  let(:base) do
    Class.new do
      attr_reader :generate

      def initialize(o)
        @generate = o
      end
    end
  end

  let(:klass) do
    Class.new(base) do
      include TabularReport::Lint
    end
  end

  subject { klass.new(output) }

  let(:valid_output) do
    {
      type: 'report-type',
      title: 'A tabular report!',
      header: [['Column 1', 'Column 2', 'Column 3']],
      footer: [['Footer 1', 'Footer 2', 'Footer 3']],
      rows: [%w(a b c), %w(d e f), %w(g h i), %w(j k l)]
    }
  end

  def self.fails_with(message)
    it "fails with the message '#{message}'" do
      expect { subject.generate }
        .to raise_error("Invalid tabular data: #{message}")
    end
  end

  context 'for valid output' do
    let(:output) { valid_output }
    it 'returns the output' do
      expect(subject.generate).to eq(valid_output)
    end
  end

  context 'with nil output' do
    let(:output) { nil }
    fails_with 'output is blank'
  end

  context 'when the header is missing' do
    let(:output) { valid_output.except(:header) }
    fails_with 'header is nil'
  end

  context 'when the header is blank' do
    let(:output) { valid_output.merge(header: []) }
    fails_with 'header is blank'
  end

  context 'when the header is an array of strings' do
    let(:output) { valid_output.merge(header: %w(a b c)) }
    fails_with 'header must be an array of arrays'
  end

  context 'when the header has too few items' do
    let(:output) { valid_output.merge(header: [%w(a b)]) }
    fails_with 'header size is incorrect'
  end

  context 'when the header contains non-string data' do
    let(:output) { valid_output.merge(header: [[1, 2, 3]]) }
    fails_with 'header fields must be strings'
  end

  context 'when the footer is missing' do
    let(:output) { valid_output.except(:footer) }
    fails_with 'footer is nil'
  end

  context 'when the footer is blank' do
    let(:output) { valid_output.merge(footer: []) }
    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end

  context 'when the footer is an array of strings' do
    let(:output) { valid_output.merge(footer: %w(a b c)) }
    fails_with 'footer must be an array of arrays'
  end

  context 'when the footer contains non-string data' do
    let(:output) { valid_output.merge(footer: [[1, 2, 3]]) }
    fails_with 'footer fields must be strings'
  end

  context 'when the footer has too few items' do
    let(:output) { valid_output.merge(footer: [%w(a b)]) }
    fails_with 'footer size is incorrect'
  end

  context 'when the row data is missing' do
    let(:output) { valid_output.except(:rows) }
    fails_with 'rows is nil'
  end

  context 'when the row data is blank' do
    let(:output) { valid_output.merge(rows: []) }
    fails_with 'rows is blank'
  end

  context 'when the row data is an array of strings' do
    let(:output) { valid_output.merge(rows: %w(a b c d e f g)) }
    fails_with 'row data must be an array of arrays'
  end

  context 'when the rows contain non-string data' do
    let(:output) { valid_output.merge(rows: [[1, 2, 3]]) }
    fails_with 'row data fields must be strings'
  end

  context 'when the rows differ in length' do
    let(:output) { valid_output.merge(rows: [%w(a b c), %w(d e)]) }
    fails_with 'row data has inconsistent width'
  end
end
