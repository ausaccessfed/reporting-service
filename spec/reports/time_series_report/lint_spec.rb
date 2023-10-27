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



  def self.fails_with(message)
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


  shared_context 'required field' do |field, type|


  end

  include_context 'required field', :type, String
  include_context 'required field', :labels, Hash
  include_context 'required field', :series, Array
  include_context 'required field', :title, String
  include_context 'required field', :data, Hash







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
