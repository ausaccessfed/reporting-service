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



  def self.fails_with(message)
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



end
