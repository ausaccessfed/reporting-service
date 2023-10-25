# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSeriesReport::Lint do
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
      labels: {
        y: 'y axis',
        series_a: 'the A series',
        series_b: 'the B series',
        series_c: 'the C series'
      },
      series: %w[series_a series_b series_c],
      units: 'Hz',
      title: 'A graph!',
      range: {
        start: 1.week.ago.xmlschema,
        end: Time.zone.now.xmlschema
      },
      data: {
        series_a: [[0, 1], [30, 2], [60, 3]],
        series_b: [[0, 11], [30, 12], [60, 13]],
        series_c: [[0, 21], [30, 22], [60, 23]]
      }
    }
  end

  let(:klass) { Class.new(base) { include TimeSeriesReport::Lint } }

  shared_examples 'fails_with' do |message|
    it "fails with the message '#{message}'" do
      expect { subject.generate }.to raise_error("Invalid time series data: #{message}")
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

  shared_context 'required field' do |field, type|
    context "with no #{field}" do
      let(:output) { valid_output.except(field) }

      it_behaves_like 'fails_with', "#{field} is nil"
    end

    context "with blank #{field}" do
      let(:output) { valid_output.merge(field => type.new) }

      it_behaves_like 'fails_with', "#{field} is blank"
    end

    context "with incorrect type for #{field}" do
      let(:wrong) { { String => Array, Array => Hash, Hash => String }[type] }
      let(:output) { valid_output.merge(field => wrong.new) }

      it_behaves_like 'fails_with', "incorrect type for #{field}"
    end
  end

  include_context 'required field', :type, String
  include_context 'required field', :labels, Hash
  include_context 'required field', :series, Array
  include_context 'required field', :title, String
  include_context 'required field', :data, Hash

  context 'when a label is missing' do
    let(:output) { valid_output.dup.tap { |o| o[:labels].delete(:series_c) } }

    it_behaves_like 'fails_with', 'missing label for series_c'
  end

  context 'when the y axis label is missing' do
    let(:output) { valid_output.dup.tap { |o| o[:labels].delete(:y) } }

    it_behaves_like 'fails_with', 'missing label for y axis'
  end

  context 'when an extra label is present' do
    let(:output) { valid_output.merge(labels: valid_output[:labels].merge(series_d: 'x')) }

    it_behaves_like 'fails_with', 'extra label present for series_d'
  end

  context 'when a label is not a string' do
    let(:output) { valid_output.merge(labels: valid_output[:labels].merge(series_a: 1234)) }

    it_behaves_like 'fails_with', 'label for series_a is not a String'
  end

  context 'when a series is named "y"' do
    let(:output) { valid_output.merge(series: valid_output[:series] + %w[y]) }

    it_behaves_like 'fails_with', 'series name "y" is not permitted'
  end

  context 'when units are missing' do
    let(:output) { valid_output.except(:units) }

    it_behaves_like 'fails_with', 'units is nil'
  end

  context 'when units are blank' do
    let(:output) { valid_output.merge(units: '') }

    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end

  context 'when range is null' do
    let(:output) { valid_output.except(:range) }

    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end
end
