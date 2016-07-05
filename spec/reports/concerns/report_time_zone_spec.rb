# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'ReportTimeZone' do
  prepend ReportTimeZone

  let(:start) { Faker::Number.number(4).to_i.days.ago.beginning_of_day }
  let(:finish) { Faker::Number.number(1).to_i.days.ago.beginning_of_day }

  describe '#convert_time_zone' do
    subject { convert_time_zone(start) }

    context 'when user defined time_zone does not exist' do
      it 'should set the report time_zone invoked from config' do
        expect(subject.zone).to eq('AEST')
      end
    end
  end

  describe '#set_time_instance_variables' do
    def run
      create_time_instance_variables(start: start, finish: finish)
    end

    it 'should define instance variable based on key/value pairs' do
      run
      expect(@start).to eq(start)
      expect(@finish).to eq(finish)
    end
  end
end