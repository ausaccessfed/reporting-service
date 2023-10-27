# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessIncomingFTicksEvents do
  subject { described_class.new }

  around { |spec| Timecop.freeze { spec.run } }


  let(:now) { Time.zone.now.beginning_of_day }

  def run
    subject.perform
  end

  before do
    create_list(:incoming_f_ticks_event, 10)
    create_list(:incoming_f_ticks_event, 10, discarded: true)
    create_list(:incoming_f_ticks_event, 10, data: 'invalid data')
  end

  context 'Process IncomingFTicksEvents' do
    it 'creates an instance of FederatedLoginEventand delete IncomingFTicksEvent' do
      expect { run }.to(change(FederatedLoginEvent, :count).by(10).and(change(IncomingFTicksEvent, :count).by(-10)))
    end

    context 'when there are incoming after or during #perform' do
      around do |example|
        Timecop.travel(now + 1) { create_list(:incoming_f_ticks_event, 2) }

        Timecop.travel(now) { example.run }

        Timecop.travel(now + 1) { create_list(:incoming_f_ticks_event, 2) }
      end

      it 'performs against events came before running the job only' do
        run
        invalid_events = IncomingFTicksEvent.where(discarded: true)
        expect(invalid_events.count).to eq 20
      end
    end
  end
end
