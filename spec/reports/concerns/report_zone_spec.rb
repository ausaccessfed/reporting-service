# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ReportZone do
  prepend ReportZone

  let(:time) { Faker::Number.number(4).to_i.days.ago.beginning_of_day }

  describe '#in_time_zone' do
    subject { convert_time_zone(time) }

    context 'when user defined time_zone does not exist' do
      it 'should set the report time_zone invoked from config' do
        expect(subject.zone).to eq('AEST')
      end
    end
  end
end
