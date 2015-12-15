require 'rails_helper'

RSpec.describe TimeSeriesReport::Lint do
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
      include TimeSeriesReport::Lint
    end
  end

  subject { klass.new(output) }

  let(:valid_output) do
    {
      type: 'report-type',
      labels: {
        y: 'y axis',
        series_a: 'the A series',
        series_b: 'the B series',
        series_c: 'the C series'
      },
      series: %w(series_a series_b series_c),
      units: 'Hz',
      title: 'A graph!',
      range: {
        start: 1.week.ago.utc.xmlschema,
        end: Time.now.utc.xmlschema
      },
      data: {
        series_a: [[0, 1], [30, 2], [60, 3]],
        series_b: [[0, 11], [30, 12], [60, 13]],
        series_c: [[0, 21], [30, 22], [60, 23]]
      }
    }
  end

  def self.fails_with(message)
    it "fails with the message '#{message}'" do
      expect { subject.generate }
        .to raise_error("Invalid time series data: #{message}")
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

  shared_context 'required field' do |field, type|
    context "with no #{field}" do
      let(:output) { valid_output.except(field) }
      fails_with "#{field} is nil"
    end

    context "with blank #{field}" do
      let(:output) { valid_output.merge(field => type.new) }
      fails_with "#{field} is blank"
    end

    context "with incorrect type for #{field}" do
      let(:wrong) do
        {
          String => Array,
          Array => Hash,
          Hash => String
        }[type]
      end
      let(:output) { valid_output.merge(field => wrong.new) }
      fails_with "incorrect type for #{field}"
    end
  end

  include_context 'required field', :type, String
  include_context 'required field', :labels, Hash
  include_context 'required field', :series, Array
  include_context 'required field', :title, String
  include_context 'required field', :data, Hash

  context 'when a label is missing' do
    let(:output) do
      valid_output.dup.tap { |o| o[:labels].delete(:series_c) }
    end

    fails_with 'missing label for series_c'
  end

  context 'when the y axis label is missing' do
    let(:output) do
      valid_output.dup.tap { |o| o[:labels].delete(:y) }
    end

    fails_with 'missing label for y axis'
  end

  context 'when an extra label is present' do
    let(:output) do
      valid_output.merge(labels: valid_output[:labels].merge(series_d: 'x'))
    end

    fails_with 'extra label present for series_d'
  end

  context 'when a label is not a string' do
    let(:output) do
      valid_output.merge(labels: valid_output[:labels].merge(series_a: 1234))
    end

    fails_with 'label for series_a is not a String'
  end

  context 'when a series is named "y"' do
    let(:output) do
      valid_output.merge(series: valid_output[:series] + %w(y))
    end

    fails_with 'series name "y" is not permitted'
  end

  context 'when units are missing' do
    let(:output) { valid_output.except(:units) }

    fails_with 'units is nil'
  end

  context 'when units are blank' do
    let(:output) { valid_output.merge(units: '') }

    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end

  context 'when the range is missing a start time' do
    let(:output) do
      valid_output.merge(range: valid_output[:range].except(:start))
    end

    fails_with 'time range is missing start'
  end

  context 'when the start time is invalid' do
    let(:output) do
      valid_output.merge(range: valid_output[:range].merge(start: 'f'))
    end

    fails_with 'start of time range is invalid'
  end

  context 'when the start time is a Time object' do
    let(:output) do
      valid_output.merge(range: valid_output[:range].merge(start: Time.now.utc))
    end

    fails_with 'start of time range is invalid'
  end

  context 'when the range is missing an end time' do
    let(:output) do
      valid_output.merge(range: valid_output[:range].except(:end))
    end

    fails_with 'time range is missing end'
  end

  context 'when the end time is invalid' do
    let(:output) do
      valid_output.merge(range: valid_output[:range].merge(end: 'f'))
    end

    fails_with 'end of time range is invalid'
  end

  context 'when the end time is a Time object' do
    let(:output) do
      valid_output.merge(range: valid_output[:range].merge(end: 'f'))
    end

    fails_with 'end of time range is invalid'
  end

  context 'when range is null' do
    let(:output) { valid_output.except(:range) }

    it 'is valid' do
      expect { subject.generate }.not_to raise_error
    end
  end

  context 'when data for a series is missing' do
    let(:output) do
      valid_output.merge(data: valid_output[:data].except(:series_a))
    end

    fails_with 'missing data for series_a'
  end

  context 'when extra series data is present' do
    let(:output) do
      valid_output.merge(data: valid_output[:data].merge(series_d: []))
    end

    fails_with 'extra data present for series_d'
  end

  context 'when the data is empty' do
    let(:output) do
      valid_output.merge(data: valid_output[:data].merge(series_a: []))
    end

    fails_with 'data for series_a is blank'
  end

  context 'when the data precedes the start of the time range' do
    let(:output) do
      data = valid_output[:data].merge(series_a: [[-1, 0]])
      valid_output.merge(data: data)
    end

    fails_with 'data for series_a is outside time range'
  end

  context 'when the data exceeds the end of the time range' do
    let(:output) do
      t = 14 * 24 * 3600
      data = valid_output[:data].merge(series_a: [[t, 0]])
      valid_output.merge(data: data)
    end

    fails_with 'data for series_a is outside time range'
  end

  context 'when the data is unsorted' do
    let(:output) do
      data = valid_output[:data].merge(series_a: [[60, 1], [30, 2], [0, 3]])
      valid_output.merge(data: data)
    end

    fails_with 'data for series_a is unsorted'
  end

  context 'when a data point is non-numeric' do
    let(:output) do
      data = valid_output[:data].merge(series_a: [0, 'a'])
      valid_output.merge(data: data)
    end

    fails_with 'data for series_a is not numeric'
  end
end
