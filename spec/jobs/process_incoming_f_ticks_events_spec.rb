require 'rails_helper'

RSpec.describe ProcessIncomingFTicksEvents do
  let!(:incoming_f_tick_event) { create :incoming_f_ticks_event }

  let!(:invalid_incoming_f_tick_event) do
    create :incoming_f_ticks_event, data: 'bad value'
  end

  subject { ProcessIncomingFTicksEvents.new }

  def run
    subject.perform
  end

  context 'Process IncomingFTicksEvents' do
    it 'should create an instance of FederatedLoginEvent'\
       'and delete IncomingFTicksEvent' do
      expect { run }.to change(FederatedLoginEvent, :count).by(1)
        .and change(IncomingFTicksEvent, :count).by(-1)
    end

    it 'should set discarded value to true if data is invalid' do
      run

      expect(IncomingFTicksEvent.all).not_to include(incoming_f_tick_event)
      expect(IncomingFTicksEvent.all).to include(invalid_incoming_f_tick_event)

      invalid_incoming = IncomingFTicksEvent.find(invalid_incoming_f_tick_event)
      expect(invalid_incoming.discarded).to eq true
    end
  end
end
