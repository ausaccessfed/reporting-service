# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TabularReport::Lint do
  subject { klass.new(output) }

  let(:base) do
    Class.new do
      attr_reader :generate

      def initialize(o)
        @generate = o
      end
    end
  end
  let(:valid_output) do
    {
      type: 'report-type',
      title: 'A tabular report!',
      header: [['Column 1', 'Column 2', 'Column 3']],
      footer: [['Footer 1', 'Footer 2', 'Footer 3']],
      rows: [%w[a b c], %w[d e f], %w[g h i], %w[j k l]]
    }
  end

  let(:klass) { Class.new(base) { include TabularReport::Lint } }

  shared_examples 'fails_with' do |message|
    it "fails with the message '#{message}'" do
      expect { subject.generate }.to raise_error("Invalid tabular data: #{message}")
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

    it_behaves_like 'fails_with', 'output is blank'
  end

  context 'when the header is missing' do
    let(:output) { valid_output.except(:header) }

    it_behaves_like 'fails_with', 'header is nil'
  end

  context 'when the header is blank' do
    let(:output) { valid_output.merge(header: []) }

    it_behaves_like 'fails_with', 'header is blank'
  end

  context 'when the header is an array of strings' do
    let(:output) { valid_output.merge(header: %w[a b c]) }

    it_behaves_like 'fails_with', 'header must be an array of arrays'
  end

  context 'when the header has too few items' do
    let(:output) { valid_output.merge(header: [%w[a b]]) }

    it_behaves_like 'fails_with', 'row data has inconsistent width'
  end

  context 'when the header contains non-string data' do
    let(:output) { valid_output.merge(header: [[1, 2, 3]]) }

    it_behaves_like 'fails_with', 'header fields must be strings'
  end

  context 'when the footer is missing' do
    let(:output) { valid_output.except(:footer) }

    it_behaves_like 'fails_with', 'footer is nil'
  end

  context 'when the footer is blank' do
    let(:output) { valid_output.merge(footer: []) }

    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end

  context 'when the row data is blank' do
    let(:output) { valid_output.merge(rows: []) }

    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end

  context 'when the footer is an array of strings' do
    let(:output) { valid_output.merge(footer: %w[a b c]) }

    it_behaves_like 'fails_with', 'footer must be an array of arrays'
  end

  context 'when the footer contains non-string data' do
    let(:output) { valid_output.merge(footer: [[1, 2, 3]]) }

    it_behaves_like 'fails_with', 'footer fields must be strings'
  end

  context 'when the footer has too few items' do
    let(:output) { valid_output.merge(footer: [%w[a b]]) }

    it_behaves_like 'fails_with', 'footer size is incorrect'
  end

  context 'when the row data is missing' do
    let(:output) { valid_output.except(:rows) }

    it_behaves_like 'fails_with', 'rows is nil'
  end

  context 'when the row data is an array of strings' do
    let(:output) { valid_output.merge(rows: %w[a b c d e f g]) }

    it_behaves_like 'fails_with', 'row data must be an array of arrays'
  end

  context 'when the rows contain non-string data' do
    let(:output) { valid_output.merge(rows: [[1, 2, 3]]) }

    it_behaves_like 'fails_with', 'row data fields must be strings'
  end

  context 'when the rows differ in length' do
    let(:output) { valid_output.merge(rows: [%w[a b c], %w[d e]]) }

    it_behaves_like 'fails_with', 'row data has inconsistent width'
  end
end
